#!/usr/bin/env python3

import sys
import json
import numpy as np

def execute_strawberry_fields_code(code):
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
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(json.dumps({'success': False, 'error': 'Usage: python3 strawberry_runner.py "<code>"'}))
        sys.exit(1)
    
    code = sys.argv[1]
    result = execute_strawberry_fields_code(code)
    print(json.dumps(result))