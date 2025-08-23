#!/usr/bin/env python3

import sys
import json
import numpy as np
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import urllib.parse

class PercevalHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Get the content length
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        # Parse the JSON data
        try:
            data = json.loads(post_data.decode('utf-8'))
            code = data.get('code', '')
            
            # Execute the Perceval code
            result = self.execute_perceval_code(code)
            
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
                'error': str(e)
            }
            self.wfile.write(json.dumps(error_response).encode('utf-8'))
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def execute_perceval_code(self, code):
        """
        Execute Perceval code and return results
        """
        try:
            # Create a namespace for execution
            namespace = {
                'np': np,
            }
            
            # Try to import Perceval
            try:
                import perceval as pcvl
                namespace['pcvl'] = pcvl
            except ImportError as e:
                return {
                    'success': False,
                    'error': f'Perceval not available: {str(e)}'
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
                    if not key.startswith('__') and key not in ['pcvl', 'np']:
                        results[key] = str(value)
            
            # Add success flag and return results at top level
            results['success'] = True
            return results
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }

if __name__ == '__main__':
    port = 8081  # Different port from Strawberry Fields
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    
    server_address = ('localhost', port)
    httpd = HTTPServer(server_address, PercevalHandler)
    print(f"Starting Perceval server on port {port}...")
    httpd.serve_forever()