import Foundation

// Simple test to capture generated code
let modes = 2
var elements: [[String]] = [["laser", "phaseShifter"], []]

print("Testing code generation...")

var code = """
import strawberryfields as sf
from strawberryfields.ops import *
import numpy as np

# Initialize program with \(modes) modes
prog = sf.Program(\(modes))

# Create engine
eng = sf.Engine("gaussian")

# Circuit definition
with prog.context as q:
"""

print("Generated code so far:")
print(code)

// Add elements
for (modeIndex, modeElements) in elements.enumerated() {
    for element in modeElements {
        let indent = "    "
        switch element {
        case "laser":
            code += "\n\(indent)# Coherent state (laser input)"
            code += "\n\(indent)Coherent(1.0) | q[\(modeIndex)]"
        case "phaseShifter":
            code += "\n\(indent)# Phase shift"
            code += "\n\(indent)Rgate(0.5) | q[\(modeIndex)]"
        default:
            break
        }
    }
}

code += """

# Run the simulation
result = eng.run(prog)

# Extract results for the app
probabilities = str(result.samples)
counts = str(result.samples)  # For now, just use the same data
success = True
"""

print("Final generated code:")
print(code)