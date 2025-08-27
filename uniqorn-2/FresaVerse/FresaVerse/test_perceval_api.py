import perceval as pcvl

# Test the correct API usage
print("Perceval version:", pcvl.__version__)

# Create a simple circuit
circuit = pcvl.Circuit(2)
circuit.add((0, 1), pcvl.BS())

print("Circuit:")
print(circuit)

# Create a basic state
input_state = pcvl.BasicState([1, 0])
print("Input state:", input_state)

# Use the correct API
processor = pcvl.Processor("SLOS", circuit)
processor.with_input(input_state)

# Sample
sampler = pcvl.algorithm.Sampler(processor)
sample_result = sampler.samples(1000)
print("Sample results:")
print(sample_result['results'][:10])  # Show first 10 results