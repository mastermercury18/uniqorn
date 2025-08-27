import perceval as pcvl
import numpy as np
from perceval.components import Unitary
import json

# Create a circuit with 2 modes
c = pcvl.Circuit(2)

# Add a beam splitter
c.add(0, pcvl.BS())

# Define input state (single photon in first mode)
input_state = pcvl.BasicState([1] + [0] * (2 - 1))

# Create processor
processor = pcvl.Processor("SLOS", c)
processor.with_input(input_state)

# Run simulation
result = processor.probs()

print("Result type:", type(result))
print("Result keys:", list(result.keys()) if hasattr(result, 'keys') else 'No keys')
print("Result:", result)

# Try to serialize
try:
    serialized = json.dumps(result, default=str)
    print("Serialization successful")
    print("Serialized:", serialized)
except Exception as e:
    print("Serialization failed:", str(e))