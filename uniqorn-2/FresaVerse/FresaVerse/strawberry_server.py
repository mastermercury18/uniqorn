#!/usr/bin/env python3

import sys
import json
import numpy as np
import traceback
from http.server import HTTPServer, BaseHTTPRequestHandler

class StrawberryFieldsHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Get the content length
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        # Parse the JSON data
        try:
            data = json.loads(post_data.decode('utf-8'))
            code = data.get('code', '')
            
            # Log the received code for debugging
            print("Received code:")
            print(code)
            
            # Execute the Strawberry Fields code
            result = self.execute_strawberry_fields_code(code)
            
            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            response = json.dumps(result)
            self.wfile.write(response.encode('utf-8'))
            
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            error_response = {
                'success': False,
                'error': str(e),
                'traceback': traceback.format_exc()
            }
            self.wfile.write(json.dumps(error_response).encode('utf-8'))
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def execute_strawberry_fields_code(self, code):
        """
        Execute Strawberry Fields code and return results
        """
        try:
            # Create a namespace for execution
            namespace = {
                'np': np,
            }
            
            # Try to import Strawberry Fields
            try:
                import strawberryfields as sf
                namespace['sf'] = sf
            except ImportError as e:
                return {
                    'success': False,
                    'error': f'Strawberry Fields not available: {str(e)}'
                }
            
            # Execute the code
            exec(code, namespace)
            
            # Extract results from the namespace
            results = {}
            
            # Look for common result variables
            result_vars = ['result', 'output', 'probabilities', 'counts', 'state']
            for var in result_vars:
                if var in namespace:
                    results[var] = str(namespace[var])
            
            # If no specific results found, return the whole namespace (excluding built-ins)
            if not results:
                for key, value in namespace.items():
                    if not key.startswith('__') and key not in ['sf', 'np']:
                        results[key] = str(value)
            
            return {
                'success': True,
                'results': results
            }
            
        except SyntaxError as e:
            return {
                'success': False,
                'error': f'Syntax error in generated code: {str(e)}',
                'traceback': traceback.format_exc()
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'traceback': traceback.format_exc()
            }

if __name__ == '__main__':
    port = 8080
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    
    server_address = ('localhost', port)
    httpd = HTTPServer(server_address, StrawberryFieldsHandler)
    print(f"Starting Strawberry Fields server on port {port}...")
    httpd.serve_forever()