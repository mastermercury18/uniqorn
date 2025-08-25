# FresaVerse 🍓🌌

FresaVerse is a macOS application that provides a visual composer for photonic quantum circuits. Users can drag and drop optical elements onto modes (wires) to design photonic quantum circuits, which are then converted into code for simulation with either Xanadu's Strawberry Fields or Quandela's Perceval frameworks.

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
  - Polarizing Beam Splitters
  - Permutations
  - Photonic Measurements
  - And more!
- **Dynamic Modes**: Add or remove optical modes (wires) as needed
- **Code Generation**: Automatically converts visual circuits to Python code for either Strawberry Fields or Perceval
- **Simulation Ready**: Generated code can be run with either framework for quantum optical simulations
- **Real-time Results**: Visualize simulation results with interactive charts and graphs

<img width="1464" height="819" alt="Screenshot 2025-08-24 at 11 43 36 PM" src="https://github.com/user-attachments/assets/7587e08b-0cb5-4fb1-b6d3-818c23263f2f" />
<img width="1463" height="823" alt="Screenshot 2025-08-24 at 11 40 06 PM" src="https://github.com/user-attachments/assets/afd16deb-d716-4e90-a6a7-44c237129f9c" />
<img width="288" height="339" alt="Screenshot 2025-08-20 at 11 10 51 AM" src="https://github.com/user-attachments/assets/52518b29-63b9-41f6-a198-393b1ab1511a" />
<img width="383" height="186" alt="Screenshot 2025-08-24 at 11 44 52 PM" src="https://github.com/user-attachments/assets/f4fc6b1c-c9e8-4874-a477-b0d78ebe1ceb" />

## How to Use

1. **Start Backend Servers**: 
   - Navigate to the FresaVerse/FresaVerse directory
   - Run `./start_servers.sh` to start both Strawberry Fields and Perceval servers
   - Alternatively, start them individually:
     - Strawberry Fields: `python3 strawberry_server.py 8080`
     - Perceval: `python3 perceval_server.py 8081`

2. **Select Framework**: Use the dropdown in the top-left to switch between Strawberry Fields and Perceval
3. **Select Elements**: Choose an optical element from the left palette
4. **Place Elements**: Tap on any mode (wire) to place the selected element
5. **Manage Circuit**: 
   - Use the "+" and "-" buttons to add or remove modes
   - Right-click (or long press) on elements to delete them
6. **Run Simulation**: 
   - Click "Run Simulation" to generate the Python code for the selected framework
   - The generated code will be sent to the appropriate backend server for simulation
   - Results will appear in the visualization panel at the bottom with interactive charts
7. **Clear**: Use the "Clear" button to reset the entire circuit

## Technology Stack

- **Frontend**: Swift/SwiftUI for macOS
- **Backend**: Python servers for Strawberry Fields and Perceval quantum photonics frameworks
- **Communication**: HTTP REST API between Swift frontend and Python backends
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
│   ├── PythonBackend.swift        # Communication with Python servers
│   ├── QuantumFramework.swift     # Framework definitions
│   ├── SimulationResultsView.swift # Results visualization
│   └── Assets.xcassets/           # App assets
├── FresaVerse.xcodeproj/          # Xcode project files
├── strawberry_server.py           # Strawberry Fields HTTP server
├── perceval_server.py              # Perceval HTTP server
├── start_servers.sh               # Script to start both servers
├── kill_ports.sh                  # Script to kill server processes
├── requirements.txt               # Python dependencies
└── README.md                      # This file
```

## Supported Optical Elements

| Element | Symbol | Description | Strawberry Fields | Perceval |
|---------|--------|-------------|-------------------|----------|
| Laser | 💡 | Creates a coherent state (laser input) | ✅ | Partial (uses single photon source) |
| Beam Splitter | 🔀 | Splits or combines optical paths | ✅ | ✅ |
| Phase Shifter | 𝜙 | Applies a phase shift to a mode | ✅ | ✅ |
| Squeezing Gate | ⇉ | Applies squeezing operation | ✅ | ❌ |
| Displacement Gate | ↗️ | Displaces a state in phase space | ✅ | ❌ |
| Kerr Gate | 🌀 | Applies Kerr nonlinearity | ✅ | ❌ |
| Photonic Measurement | 🔍 | Measures photonic states | ✅ | Partial (implicit in Perceval) |

## Setting Up Backend Servers

FresaVerse requires Python backend servers to run simulations. Follow these steps to set up:

### Prerequisites
- Python 3.8 or later
- Required Python packages (install with `pip install -r requirements.txt`):
  - strawberryfields
  - perceval-quandela
  - numpy
  - scipy

### Starting the Servers

1. **Automatic Method** (recommended):
   ```bash
   cd FresaVerse/FresaVerse
   ./start_servers.sh
   ```

2. **Manual Method**:
   ```bash
   # Terminal 1: Start Strawberry Fields server
   cd FresaVerse/FresaVerse
   python3 strawberry_server.py 8080
   
   # Terminal 2: Start Perceval server
   cd FresaVerse/FresaVerse
   python3 perceval_server.py 8081
   ```

### Stopping the Servers

- **Automatic Method**: 
  ```bash
  ./kill_ports.sh
  ```
  
- **Manual Method**: Use Ctrl+C in each terminal, or:
  ```bash
  pkill -f "strawberry_server.py"
  pkill -f "perceval_server.py"
  ```

## Code Generation

When you click "Run Simulation", FresaVerse generates equivalent Python code for the selected framework and sends it to the appropriate backend server.

### For Strawberry Fields:
```python
import strawberryfields as sf
from strawberryfields.ops import *
import numpy as np

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

# Extract probabilities and counts for display
state = result.state
probabilities = state.all_fock_probs(cutoff=3)
```

### For Perceval:
```python
import perceval as pcvl
import numpy as np

# Initialize circuit with 2 modes
circuit = pcvl.Circuit(2)

# Beam splitter between mode 0 and 1
circuit.add((0, 1), pcvl.BS())

# Add input state (single photon in mode 0, vacuum in others)
input_state = pcvl.BasicState([1, 0])

# Create processor and simulator
processor = pcvl.Processor("SLOS", circuit)
processor.with_input(input_state)

# Run simulation using sampler
sampler = pcvl.algorithm.Sampler(processor)
sample_result = sampler.samples(1000)
```

## Requirements

- Xcode 16.4 or later
- macOS 14.0 or later for development
- Python 3.8 or later with dependencies listed in `requirements.txt`

## Troubleshooting

### Common Issues

1. **Connection Refused Errors**: 
   - Ensure both backend servers are running
   - Check that ports 8080 and 8081 are not blocked by firewall
   - Use `lsof -i :8080` and `lsof -i :8081` to verify servers are listening

2. **Python Package Issues**:
   - Install dependencies: `pip install -r requirements.txt`
   - For Strawberry Fields compatibility: May require specific SciPy version

3. **Server Startup Failures**:
   - Kill existing processes: `./kill_ports.sh`
   - Restart servers: `./start_servers.sh`

### Server Management Scripts

- `start_servers.sh`: Starts both servers in the background
- `kill_ports.sh`: Kills processes using ports 8080 and 8081
- `strawberry_server.py`: Runs Strawberry Fields server on port 8080
- `perceval_server.py`: Runs Perceval server on port 8081

## Future Enhancements

- Integration with additional quantum photonic frameworks
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
