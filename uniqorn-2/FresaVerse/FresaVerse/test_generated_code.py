import Foundation

// Test the code generation
let testCode = """
import strawberryfields as sf
from strawberryfields.ops import *
import numpy as np

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

# Extract results for the app
probabilities = str(result.samples)
counts = str(result.samples)  # For now, just use the same data
success = True
"""

print("Testing generated code:")
print(testCode)

// Try to compile the code to check for syntax errors
import sys
import subprocess

// Write the code to a temporary file
with open("temp_code.py", "w") as f:
    f.write(testCode)

// Try to run the code
try:
    result = subprocess.run([sys.executable, "-m", "py_compile", "temp_code.py"], capture_output=True, text=True)
    if result.returncode == 0:
        print("Code compiles successfully")
    else:
        print("Compilation error:")
        print(result.stderr)
except Exception as e:
    print("Error checking code:", str(e))