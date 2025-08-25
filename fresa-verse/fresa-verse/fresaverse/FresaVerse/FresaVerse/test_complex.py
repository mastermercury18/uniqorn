import json
import urllib.request
import urllib.parse

# More complex successful code that generates results
code = '''
# Simple simulation that generates some results
result = "Simulation completed successfully"
probabilities = {"00": 0.5, "01": 0.25, "10": 0.25, "11": 0.0}
counts = {"00": 500, "01": 250, "10": 250, "11": 0}
success = True
'''

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
    print("Complex success response:", result)
    
    # Parse the JSON
    import json
    parsed = json.loads(result)
    print("Parsed response:", parsed)
    print("Success field:", parsed.get("success", "Not found"))
    print("All keys:", list(parsed.keys()))
except Exception as e:
    print("Request error:", str(e))