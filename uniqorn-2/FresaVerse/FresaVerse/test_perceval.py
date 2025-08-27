import perceval as pcvl
import numpy as np

print("Perceval version:", pcvl.__version__)

# Create a simple circuit
circuit = pcvl.Circuit(2)
circuit.add((0, 1), pcvl.BS())

print("Circuit:")
print(circuit)

# Create a basic state
input_state = pcvl.BasicState([1, 0])
print("Input state:", input_state)

# Try different ways to simulate
try:
    # Method 1: Direct backend
    backend = pcvl.BackendFactory.get_backend("SLOS")
    backend.set_circuit(circuit)
    
    # Get probability amplitude
    amplitude = backend.prob_amplitude(input_state, input_state)
    print("Probability amplitude:", amplitude)
    
    # Get probability
    prob = backend.probability(input_state, input_state)
    print("Probability:", prob)
    
except Exception as e:
    print("Method 1 failed:", e)
    import traceback
    traceback.print_exc()

try:
    # Method 2: Using Processor
    processor = pcvl.Processor("SLOS", circuit)
    processor.with_input(input_state)
    
    # Sample
    sampler = pcvl.algorithm.Sampler(processor)
    results = sampler.samples(1000)
    print("Sampling results:", results)
    
except Exception as e:
    print("Method 2 failed:", e)
    import traceback
    traceback.print_exc()