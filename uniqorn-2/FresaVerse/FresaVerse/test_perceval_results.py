import perceval as pcvl
import numpy as np

# Simple test to see what probs() returns
c = pcvl.Circuit(2)
c.add(0, pcvl.BS())

# Define input state
input_state = pcvl.BasicState([1, 0])

# Create processor
processor = pcvl.Processor("SLOS", c)
processor.with_input(input_state)

# Run simulation
result = processor.probs()

print("Type of result:", type(result))
print("Result:", result)

# Check if it has methods to get probabilities
if hasattr(result, 'keys'):
    print("Result has keys method")
    for key in result.keys():
        print(f"Key: {key}, Value: {result[key]}")

# Check if it's a distribution object
if hasattr(result, 'items'):
    print("Result has items method")
    for key, value in result.items():
        print(f"Item - Key: {key}, Value: {value}")