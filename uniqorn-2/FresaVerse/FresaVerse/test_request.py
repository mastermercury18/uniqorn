# Simple Strawberry Fields code
code = '''
import strawberryfields as sf
from strawberryfields.ops import *

# Initialize program with 2 modes
prog = sf.Program(2)

# Create engine
eng = sf.Engine("gaussian")

# Circuit definition
with prog.context as q:
    # Coherent state (laser input)
    Coherent(1.0) | q[0]
    # Phase shift
    Rgate(0.5) | q[0]

# Run the simulation
result = eng.run(prog)

# Extract results
probabilities = str(result.samples)
state = str(result.state)
success = True

# Simple JSON-like output (we'll parse this on the client side)
print('{"success": true, "probabilities": "' + probabilities + '", "state": "' + state + '"}')
'''

print("Sending code to server:")
print(code)

import json
import urllib.request
import urllib.parse

# Create request
data = json.dumps({"code": code}).encode('utf-8')
req = urllib.request.Request(
    'http://localhost:8080',
    data=data,
    headers={'Content-Type': 'application/json'}
)

# Send request and get response
try:
    response = urllib.request.urlopen(req)
    result = response.read().decode('utf-8')
    print("Server response:", result)
    
    # Try to parse the JSON
    try:
        parsed_result = json.loads(result)
        print("Parsed result:", parsed_result)
    except json.JSONDecodeError as e:
        print("Failed to parse JSON:", str(e))
        print("Raw response:", repr(result))
except Exception as e:
    print("Request error:", str(e))