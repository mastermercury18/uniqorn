import json
import urllib.request
import urllib.parse

# Test code that will cause an error
code = '''
# This will cause an error because x is not defined
print(x)
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
    print("Error response:", result)
except Exception as e:
    print("Request error:", str(e))