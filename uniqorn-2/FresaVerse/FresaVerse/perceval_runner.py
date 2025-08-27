#!/usr/bin/env python3

import sys
import json
import numpy as np

def execute_perceval_code(code):
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
        print(json.dumps({'success': False, 'error': 'Usage: python3 perceval_runner.py "<code>"'}))
        sys.exit(1)
    
    code = sys.argv[1]
    result = execute_perceval_code(code)
    print(json.dumps(result))