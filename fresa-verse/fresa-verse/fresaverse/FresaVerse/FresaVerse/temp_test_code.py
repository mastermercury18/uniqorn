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