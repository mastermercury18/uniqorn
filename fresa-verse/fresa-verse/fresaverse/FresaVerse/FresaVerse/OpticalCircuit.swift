import Foundation
import CoreGraphics

enum QuantumFramework: String, CaseIterable {
    case strawberryFields = "Strawberry Fields"
    case perceval = "Perceval"
    
    var displayName: String {
        return self.rawValue
    }
}

class OpticalCircuit: ObservableObject {
    @Published var elements: [OpticalElement] = []
    @Published var modes: Int = 2  // Number of optical modes (wires)
    @Published var results: String = ""
    
    func addElement(_ element: OpticalElement) {
        elements.append(element)
        // Keep elements sorted by position for proper rendering
        elements.sort { $0.position.x < $1.position.x }
    }
    
    func removeElement(_ element: OpticalElement) {
        elements.removeAll { $0.id == element.id }
    }
    
    func clearCircuit() {
        elements.removeAll()
        results = ""
    }
    
    func generateCode(for framework: QuantumFramework) -> String {
        switch framework {
        case .strawberryFields:
            return generateStrawberryFieldsCode()
        case .perceval:
            return generatePercevalCode()
        }
    }
    
    func generateStrawberryFieldsCode() -> String {
        var code = """
        import strawberryfields as sf
        from strawberryfields.ops import *
        import numpy as np
        
        # Initialize program with \(modes) modes
        prog = sf.Program($modes)
        
        # Create engine
        eng = sf.Engine("gaussian")
        
        # Circuit definition
        with prog.context as q:
        """
        
        // Group elements by mode and sort by position
        var elementsByMode: [[OpticalElement]] = Array(repeating: [], count: modes)
        for element in elements {
            if element.mode < modes {
                elementsByMode[element.mode].append(element)
            }
        }
        
        // Sort each mode's elements by position
        for i in 0..<modes {
            elementsByMode[i].sort { $0.position.x < $1.position.x }
        }
        
        // Generate code for each element
        // First, place all single-mode elements
        for (modeIndex, modeElements) in elementsByMode.enumerated() {
            for element in modeElements {
                let indent = "    "
                switch element.type {
                case .laser:
                    code += "\n\(indent)# Coherent state (laser input)"
                    code += "\n\(indent)Coherent(1.0) | q[\(modeIndex)]"
                case .phaseShifter:
                    let phi = element.parameters["phi"] ?? 0.5
                    code += "\n\(indent)# Phase shift"
                    code += "\n\(indent)Rgate(\(phi)) | q[\(modeIndex)]"
                case .squeezeGate:
                    let r = element.parameters["r"] ?? 0.5
                    let theta = element.parameters["theta"] ?? 0.0
                    code += "\n\(indent)# Squeezing operation"
                    code += "\n\(indent)Sgate(\(r), \(theta)) | q[\(modeIndex)]"
                case .displacementGate:
                    let r = element.parameters["r"] ?? 0.5
                    let phi = element.parameters["phi"] ?? 0.0
                    code += "\n\(indent)# Displacement operation"
                    code += "\n\(indent)Dgate(\(r), \(phi)) | q[\(modeIndex)]"
                case .kerrGate:
                    let kappa = element.parameters["kappa"] ?? 0.1
                    code += "\n\(indent)# Kerr nonlinearity"
                    code += "\n\(indent)Kgate(\(kappa)) | q[\(modeIndex)]"
                case .measure:
                    code += "\n\(indent)# Photonic measurement"
                    code += "\n\(indent)MeasureFock() | q[\(modeIndex)]"
                case .halfWavePlate, .quarterWavePlate, .permutation, .polarizingBeamSplitter, .timeDelay, .unitary:
                    // These are Perceval-specific elements
                    code += "\n\(indent)# Note: \(element.type.rawValue) is a Perceval-specific element"
                    code += "\n\(indent)# This element is not available in Strawberry Fields"
                case .beamSplitter:
                    // We'll handle beam splitters separately
                    break
                }
            }
        }
        
        // Then, handle beam splitters (which connect modes)
        for (modeIndex, modeElements) in elementsByMode.enumerated() {
            for element in modeElements {
                switch element.type {
                case .beamSplitter:
                    let indent = "    "
                    let theta = element.parameters["theta"] ?? 0.5
                    let phi = element.parameters["phi"] ?? Double.pi/4
                    // Beam splitters connect two modes
                    if modeIndex < modes - 1 {
                        code += "\n\(indent)# Beam splitter between mode \(modeIndex) and \(modeIndex + 1)"
                        code += "\n\(indent)BSgate(\(theta), \(phi)) | (q[\(modeIndex)], q[\(modeIndex + 1)])"
                    } else {
                        code += "\n\(indent)# Note: Beam splitter at mode \(modeIndex) has no adjacent mode to connect to"
                    }
                case .permutation, .polarizingBeamSplitter, .unitary:
                    // These are Perceval-specific multi-mode elements
                    code += "\n# Note: \(element.type.rawValue) is a Perceval-specific element"
                    code += "\n# This element is not available in Strawberry Fields"
                case .halfWavePlate, .quarterWavePlate, .timeDelay:
                    // These are single-mode elements already handled above
                    break
                default:
                    // Other elements already handled
                    break
                }
            }
        }
        
        code += """


        # Run the simulation
        result = eng.run(prog)
        
        # Display results
        print("Measurement results:", result.samples)
        print("State:", result.state)
        """
        
        return code
    }
    
    func generatePercevalCode() -> String {
        var code = """
        import perceval as pcvl
        import numpy as np
        from perceval.components import Unitary
        
        # Create a circuit with \(modes) modes
        c = pcvl.Circuit(\(modes))
        """
        
        // Group elements by mode and sort by position
        var elementsByMode: [[OpticalElement]] = Array(repeating: [], count: modes)
        for element in elements {
            if element.mode < modes {
                elementsByMode[element.mode].append(element)
            }
        }
        
        // Sort each mode's elements by position
        for i in 0..<modes {
            elementsByMode[i].sort { $0.position.x < $1.position.x }
        }
        
        // Generate code for each element
        // First, place all single-mode elements
        for (modeIndex, modeElements) in elementsByMode.enumerated() {
            for element in modeElements {
                switch element.type {
                case .laser:
                    // Perceval doesn't have a direct equivalent to a laser
                    // We'll use a single photon source as a basic input
                    code += "\n# Single photon input (basic laser equivalent)"
                    code += "\nc //= (0, pcvl.Source(emission_probability=1))"  // Simplified
                case .phaseShifter:
                    let phi = element.parameters["phi"] ?? 0.5
                    code += "\n# Phase shifter on mode \(modeIndex)"
                    code += "\nc.add(\(modeIndex), pcvl.PS(\(phi)))"
                case .halfWavePlate:
                    let theta = element.parameters["theta"] ?? 0.0
                    code += "\n# Half wave plate on mode \(modeIndex)"
                    code += "\nc.add(\(modeIndex), pcvl.HWP(\(theta)))"
                case .quarterWavePlate:
                    let theta = element.parameters["theta"] ?? 0.0
                    code += "\n# Quarter wave plate on mode \(modeIndex)"
                    code += "\nc.add(\(modeIndex), pcvl.QWP(\(theta)))"
                case .timeDelay:
                    let delay = element.parameters["delay"] ?? 1.0
                    code += "\n# Time delay on mode \(modeIndex)"
                    code += "\nc.add(\(modeIndex), pcvl.TD(\(delay)))"
                case .squeezeGate, .displacementGate, .kerrGate:
                    // These don't have direct equivalents in Perceval
                    code += "\n# Note: \(element.type.rawValue) not directly supported in Perceval"
                case .measure:
                    // Measurement is implicit in Perceval
                    code += "\n# Photonic measurement (implicit in Perceval)"
                case .beamSplitter, .permutation, .polarizingBeamSplitter, .unitary:
                    // We'll handle these separately
                    break
                }
            }
        }
        
        // Then, handle multi-mode elements
        for (modeIndex, modeElements) in elementsByMode.enumerated() {
            for element in modeElements {
                switch element.type {
                case .beamSplitter:
                    let theta = element.parameters["theta"] ?? 0.5
                    let phi = element.parameters["phi"] ?? Double.pi/4
                    // Beam splitters connect two modes
                    if modeIndex < modes - 1 {
                        code += "\n# Beam splitter between mode \(modeIndex) and \(modeIndex + 1)"
                        code += "\nc.add((\(modeIndex), \(modeIndex + 1)), pcvl.BS(theta=\(theta), phi_bl=\(phi)))"
                    } else {
                        code += "\n# Note: Beam splitter at mode \(modeIndex) has no adjacent mode to connect to"
                    }
                case .permutation:
                    // For permutation, we need to specify the permutation pattern
                    code += "\n# Permutation (example: swap modes 0 and 1 if they exist)"
                    if modes >= 2 {
                        code += "\nperm_circuit = pcvl.PERM([1, 0])"
                        code += "\nc.add((0, 1), perm_circuit)"
                    }
                case .polarizingBeamSplitter:
                    code += "\n# Polarizing beam splitter (example implementation)"
                    code += "\n# Note: PBS requires additional setup for polarization states"
                    code += "\n# pbs = pcvl.PBS()"
                    code += "\n# c.add(\(modeIndex), pbs)"
                case .unitary:
                    code += "\n# Unitary transformation (example 2x2 matrix)"
                    code += "\n# Define a 2x2 unitary matrix"
                    code += "\nunitary_matrix = np.array([[1, 0], [0, 1]])  # Identity matrix as example"
                    code += "\nunitary_component = Unitary(unitary_matrix)"
                    if modeIndex < modes - 1 {
                        code += "\nc.add((\(modeIndex), \(modeIndex + 1)), unitary_component)"
                    }
                default:
                    // Other elements already handled
                    break
                }
            }
        }
        
        // Add input state - create a basic state with one photon in the first mode
        code += "\n\n# Define input state (single photon in first mode)"
        code += "\ninput_state = pcvl.BasicState([1] + [0] * (\(modes) - 1))"
        code += "\n\n# Create processor"
        code += "\nprocessor = pcvl.Processor(\"SLOS\", c)"
        code += "\n\n# Run simulation"
        code += "\nprocessor.with_input(input_state)"
        code += "\nresult = processor.probs()"
        code += "\n\n# Display results"
        code += "\nprint(\"Probabilities:\", result)"
        
        return code
    }
}