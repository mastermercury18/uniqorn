import json
import urllib.request
import urllib.parse

# Simple successful code
code = '''
print("Hello from simulation")
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
    print("Success response:", result)
    
    # Parse the JSON
    import json
    parsed = json.loads(result)
    print("Parsed response:", parsed)
    print("Success field:", parsed.get("success", "Not found"))
except Exception as e:
    print("Request error:", str(e))