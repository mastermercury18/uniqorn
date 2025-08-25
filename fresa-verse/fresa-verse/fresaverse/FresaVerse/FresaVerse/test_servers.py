#!/usr/bin/env python3

import requests
import json

def test_strawberry_fields():
    """Test the Strawberry Fields server"""
    print("Testing Strawberry Fields server...")
    
    # Sample Strawberry Fields code
    code = """
import strawberryfields as sf
from strawberryfields.ops import *

# Create a program
prog = sf.Program(2)

with prog.context as q:
    # State preparation
    Sgate(0.5) | q[0]
    Sgate(0.5) | q[1]
    
    # Apply beamsplitter
    BSgate(0.4, 0.2) | (q[0], q[1])

# Run the simulation
eng = sf.Engine("gaussian")
result = eng.run(prog)

# Extract probabilities
probabilities = result.state.all_fock_probs(cutoff=3)
output = {"probabilities": str(probabilities)}
"""
    
    try:
        response = requests.post(
            "http://localhost:8080",
            json={"code": code},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✓ Strawberry Fields server test passed")
        else:
            print("✗ Strawberry Fields server test failed")
            
    except Exception as e:
        print(f"✗ Strawberry Fields server test failed with error: {e}")

def test_perceval():
    """Test the Perceval server"""
    print("\nTesting Perceval server...")
    
    # Sample Perceval code
    code = """
import perceval as pcvl
import numpy as np

# Create a simple circuit
circuit = pcvl.Circuit(2)
circuit.add(0, pcvl.BS())
circuit.add(1, pcvl.PS(phi=0.5))

# Create a processor
processor = pcvl.Processor("SLOS", circuit)
processor.with_input(pcvl.BasicState([1, 1]))

# Run the simulation
sampler = pcvl.algorithm.Sampler(processor)
result = sampler.sample()

# Extract results
output = {"result": str(result)}
"""
    
    try:
        response = requests.post(
            "http://localhost:8081",
            json={"code": code},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✓ Perceval server test passed")
        else:
            print("✗ Perceval server test failed")
            
    except Exception as e:
        print(f"✗ Perceval server test failed with error: {e}")

if __name__ == "__main__":
    test_strawberry_fields()
    test_perceval()