#!/usr/bin/env python3

import requests
import json

def test_strawberry_fields():
    """Test the Strawberry Fields server"""
    print("Testing Strawberry Fields server...")
    
    # Sample Strawberry Fields code that should work
    code = """
import strawberryfields as sf
from strawberryfields.ops import *

# Create a program with 2 modes
prog = sf.Program(2)

# Apply some operations
with prog.context as q:
    Sgate(0.5) | q[0]
    Sgate(0.5) | q[1]
    BSgate(0.4, 0.2) | (q[0], q[1])

# Run the simulation
eng = sf.Engine("gaussian")
result = eng.run(prog)

# Create some mock results for testing
probabilities = {"00": 0.4, "01": 0.3, "10": 0.2, "11": 0.1}
counts = {"00": 400, "01": 300, "10": 200, "11": 100}
output = "Simulation completed successfully"
"""
    
    try:
        response = requests.post(
            "http://localhost:8080",
            json={"code": code},
            headers={"Content-Type": "application/json"},
            timeout=10
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
    
    # Sample Perceval code that should work
    code = """
import perceval as pcvl
import numpy as np

# Create a simple circuit
circuit = pcvl.Circuit(2)
circuit.add(0, pcvl.BS())
circuit.add(1, pcvl.PS(phi=0.5))

# Create some mock results for testing
result = "Perceval simulation completed"
probabilities = {"00": 0.5, "01": 0.25, "10": 0.15, "11": 0.1}
counts = {"00": 500, "01": 250, "10": 150, "11": 100}
output = "Perceval simulation completed successfully"
"""
    
    try:
        response = requests.post(
            "http://localhost:8081",
            json={"code": code},
            headers={"Content-Type": "application/json"},
            timeout=10
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