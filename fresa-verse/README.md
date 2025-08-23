# FresaVerse 🍓🌌

FresaVerse is a macOS application that provides a visual composer for photonic quantum circuits. Users can drag and drop optical elements onto modes (wires) to design photonic quantum circuits, which are then converted into code for simulation with either Xanadu's Strawberry Fields or Perceval frameworks.

## Features

- **Visual Circuit Design**: Intuitive drag-and-drop interface for creating photonic quantum circuits
- **Framework Toggle**: Switch between Strawberry Fields and Perceval backends
- **Optical Elements**: Supports various optical elements including:
  - Lasers (Coherent states)
  - Beam Splitters
  - Phase Shifters
  - Squeezing Gates
  - Displacement Gates
  - Kerr Gates
  - Photonic Measurements
- **Dynamic Modes**: Add or remove optical modes (wires) as needed
- **Code Generation**: Automatically converts visual circuits to Python code for either Strawberry Fields or Perceval
- **Simulation Ready**: Generated code can be run with either framework for quantum optical simulations

<img width="1469" height="915" alt="Screenshot 2025-08-20 at 11 07 07 AM" src="https://github.com/user-attachments/assets/b2f93936-0d11-47b7-b9fd-eeffcd4583e9" />
<img width="288" height="339" alt="Screenshot 2025-08-20 at 11 10 51 AM" src="https://github.com/user-attachments/assets/52518b29-63b9-41f6-a198-393b1ab1511a" />
<img width="1264" height="351" alt="Screenshot 2025-08-20 at 11 11 19 AM" src="https://github.com/user-attachments/assets/e639cb38-044e-4268-8c39-008fb91cb16d" />

## How to Use

1. **Select Framework**: Use the dropdown in the top-left to switch between Strawberry Fields and Perceval
2. **Select Elements**: Choose an optical element from the left palette
3. **Place Elements**: Tap on any mode (wire) to place the selected element
4. **Manage Circuit**: 
   - Use the "+" and "-" buttons to add or remove modes
   - Right-click (or long press) on elements to delete them
5. **Run Simulation**: 
   - Click "Run Simulation" to generate the Python code for the selected framework
   - The generated code will appear in the results panel at the bottom
6. **Clear**: Use the "Clear" button to reset the entire circuit

## Technology Stack

- **Frontend**: Swift/SwiftUI for macOS
- **Backend**: Designed to work with both Xanadu's Strawberry Fields and Perceval quantum photonics frameworks
- **Architecture**: Model-View pattern with ObservableObject for state management

## Project Structure

```
FresaVerse/
├── FresaVerse/
│   ├── ContentView.swift          # Main view
│   ├── FresaVerseApp.swift        # App entry point
│   ├── OpticalElement.swift       # Optical element models
│   ├── OpticalCircuit.swift       # Circuit logic and code generation
│   ├── OpticalElementViews.swift  # UI components for elements
│   ├── CircuitView.swift          # Main circuit view
│   └── Assets.xcassets/           # App assets
├── FresaVerse.xcodeproj/          # Xcode project files
└── README.md                      # This file
```

## Supported Optical Elements

| Element | Symbol | Description | Perceval Support |
|---------|--------|-------------|------------------|
| Laser | 💡 | Creates a coherent state (laser input) | Partial (uses single photon source) |
| Beam Splitter | 🔀 | Splits or combines optical paths | ✅ |
| Phase Shifter | 𝜙 | Applies a phase shift to a mode | ✅ |
| Squeezing Gate | ⇉ | Applies squeezing operation | ❌ |
| Displacement Gate | ↗️ | Displaces a state in phase space | ❌ |
| Kerr Gate | 🌀 | Applies Kerr nonlinearity | ❌ |
| Photonic Measurement | 🔍 | Measures photonic states | Partial (implicit in Perceval) |

## Code Generation

When you click "Run Simulation", FresaVerse generates equivalent Python code for the selected framework.

For Strawberry Fields:
```python
import strawberryfields as sf
from strawberryfields.ops import *

# Initialize program with 2 modes
prog = sf.Program(2)

# Create engine
eng = sf.Engine("gaussian")

# Circuit definition
with prog.context as q:
    Coherent(1.0) | q[0]
    BSgate(0.5, 0.0) | (q[0], q[1])

# Run the simulation
result = eng.run(prog)

# Display results
print("Measurement results:", result.samples)
```

For Perceval:
```python
import perceval as pcvl

# Create a circuit with 2 modes
c = pcvl.Circuit(2)

# Beam splitter between mode 0 and 1
c.add((0, 1), pcvl.BS(theta=0.5, phi_bl=0.0))

# Define input state (example with single photons)
input_state = pcvl.BasicState([1, 0])

# Select backend
backend = pcvl.BackendFactory.get_backend("SLOS")

# Create simulator
simulator = backend.Simulator(c.U)

# Run simulation
result = simulator.probs(input_state)

# Display results
print("Probabilities:", result)
```

## Requirements

- Xcode 16.4 or later
- macOS 14.0 or later for development
- Python 3.8 or later with either:
  - Strawberry Fields installed (`pip install strawberryfields`)
  - Perceval installed (`pip install perceval-quandela`)

## Future Enhancements

- Integration with actual backends for real simulation
- More sophisticated circuit validation
- Export/import functionality for circuits
- Advanced parameter editing for optical elements
- Visualization of quantum states
- Tutorial and documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Xanadu for the Strawberry Fields framework
- Quandela for the Perceval framework
- Inspired by IBM's Quantum Circuit Composer
