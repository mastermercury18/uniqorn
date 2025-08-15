# FresaVerse

FresaVerse is an iOS application that provides a visual composer for photonic quantum circuits, similar to IBM's Quantum Circuit Composer but using Xanadu's Strawberry Fields framework instead of Qiskit. Users can drag and drop optical elements onto modes (wires) to design photonic quantum circuits, which are then converted into Strawberry Fields code for simulation.

## Features

- **Visual Circuit Design**: Intuitive drag-and-drop interface for creating photonic quantum circuits
- **Optical Elements**: Supports various optical elements including:
  - Lasers (Coherent states)
  - Beam Splitters
  - Phase Shifters
  - Squeezing Gates
  - Displacement Gates
  - Kerr Gates
  - Photonic Measurements
- **Dynamic Modes**: Add or remove optical modes (wires) as needed
- **Code Generation**: Automatically converts visual circuits to Strawberry Fields Python code
- **Simulation Ready**: Generated code can be run with Strawberry Fields for quantum optical simulations

<img width="1190" height="735" alt="Screenshot 2025-08-15 at 10 06 12 AM" src="https://github.com/user-attachments/assets/328a16ec-7b6d-445d-a2c6-f1883c50df59" />

## How to Use

1. **Select Elements**: Choose an optical element from the left palette
2. **Place Elements**: Tap on any mode (wire) to place the selected element
3. **Manage Circuit**: 
   - Use the "+" and "-" buttons to add or remove modes
   - Right-click (or long press) on elements to delete them
4. **Run Simulation**: 
   - Click "Run Simulation" to generate the Strawberry Fields code
   - The generated code will appear in the results panel at the bottom
5. **Clear**: Use the "Clear" button to reset the entire circuit

## Technology Stack

- **Frontend**: Swift/SwiftUI for iOS
- **Backend**: Designed to work with Xanadu's Strawberry Fields quantum photonics framework
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

| Element | Symbol | Description |
|---------|--------|-------------|
| Laser | 💡 | Creates a coherent state (laser input) |
| Beam Splitter | 🔀 | Splits or combines optical paths |
| Phase Shifter | 𝜙 | Applies a phase shift to a mode |
| Squeezing Gate | ⇉ | Applies squeezing operation |
| Displacement Gate | ↗️ | Displaces a state in phase space |
| Kerr Gate | 🌀 | Applies Kerr nonlinearity |
| Photonic Measurement | 🔍 | Measures photonic states |

## Code Generation

When you click "Run Simulation", FresaVerse generates equivalent Strawberry Fields code. For example, a simple circuit with a laser and beam splitter would generate:

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

## Requirements

- Xcode 16.4 or later
- iOS 18.5 or later (for simulator)
- macOS 14.0 or later for development

## Future Enhancements

- Integration with actual Strawberry Fields backend for real simulation
- More sophisticated circuit validation
- Export/import functionality for circuits
- Advanced parameter editing for optical elements
- Visualization of quantum states
- Tutorial and documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Xanadu for the Strawberry Fields framework
- Inspired by IBM's Quantum Circuit Composer
