import Foundation
import CoreGraphics

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
                case .beamSplitter:
                    // We'll handle beam splitters separately
                    break
                }
            }
        }
        
        // Then, handle beam splitters (which connect modes)
        for (modeIndex, modeElements) in elementsByMode.enumerated() {
            for element in modeElements {
                if element.type == .beamSplitter {
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
}