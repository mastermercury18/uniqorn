import json
import urllib.request
import urllib.parse

# Test Perceval code with proper handling of FockState objects
code = '''
import perceval as pcvl
import numpy as np
from perceval.components import Unitary

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

# Extract probabilities in a structured way
probabilities = {}
try:
    if 'results' in result:
        dist = result['results']
        if hasattr(dist, 'items'):
            for state, prob in dist.items():
                # Convert FockState to string key
                key_str = str(state)  # This should work
                # Convert probability to float
                prob_float = float(prob)
                probabilities[key_str] = prob_float
        else:
            # Fallback for different result formats
            probabilities = str(result)
    else:
        # Fallback for different result formats
        probabilities = str(result)
except Exception as e:
    probabilities = {"error": f"Error extracting probabilities: {str(e)}"}

# Extract counts (for histogram display)
counts = {}
try:
    # Generate sample counts based on probabilities (for visualization)
    if isinstance(probabilities, dict) and "error" not in probabilities:
        total_samples = 1000
        for state, prob in probabilities.items():
            count = int(prob * total_samples)
            if count > 0:
                counts[state] = count
    else:
        counts = {"error": "Could not generate counts from probabilities"}
except Exception as e:
    counts = {"error": f"Error generating counts: {str(e)}"}

# Mark as successful
success = True
'''

# Create request
data = json.dumps({"code": code}).encode('utf-8')
req = urllib.request.Request(
    'http://localhost:8081',
    data=data,
    headers={'Content-Type': 'application/json'}
)

# Send request and get response
try:
    response = urllib.request.urlopen(req)
    result = response.read().decode('utf-8')
    print("Perceval response:", result)
    
    # Parse the JSON
    import json
    parsed = json.loads(result)
    print("Parsed response:", parsed)
    print("Success field:", parsed.get("success", "Not found"))
    print("Probabilities type:", type(parsed.get("probabilities", "Not found")))
    if "probabilities" in parsed:
        print("Probabilities content:", parsed["probabilities"])
    print("Counts type:", type(parsed.get("counts", "Not found")))
    if "counts" in parsed:
        print("Counts content:", parsed["counts"])
except Exception as e:
    print("Request error:", str(e))