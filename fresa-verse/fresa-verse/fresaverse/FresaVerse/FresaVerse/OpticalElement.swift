import Foundation

enum OpticalElementType: String, CaseIterable {
    case laser = "Laser"
    case beamSplitter = "Beam Splitter"
    case phaseShifter = "Phase Shifter"
    case squeezeGate = "Squeezing Gate"
    case displacementGate = "Displacement Gate"
    case kerrGate = "Kerr Gate"
    case measure = "Photonic Measurement"
    // Perceval-specific elements
    case halfWavePlate = "Half Wave Plate"
    case quarterWavePlate = "Quarter Wave Plate"
    case permutation = "Permutation"
    case polarizingBeamSplitter = "Polarizing Beam Splitter"
    case timeDelay = "Time Delay"
    case unitary = "Unitary"
    
    var symbol: String {
        switch self {
        case .laser:
            return "💡"
        case .beamSplitter:
            return "🔀"
        case .phaseShifter:
            return "𝜙"
        case .squeezeGate:
            return "⇉"
        case .displacementGate:
            return "↗️"
        case .kerrGate:
            return "🌀"
        case .measure:
            return "🔍"
        case .halfWavePlate:
            return "½λ"
        case .quarterWavePlate:
            return "¼λ"
        case .permutation:
            return "🔄"
        case .polarizingBeamSplitter:
            return "✨"
        case .timeDelay:
            return "🕙"
        case .unitary:
            return "🅤"
        }
    }
    
    var description: String {
        switch self {
        case .laser:
            return "Creates a coherent state (laser input)"
        case .beamSplitter:
            return "Splits or combines optical paths"
        case .phaseShifter:
            return "Applies a phase shift to a mode"
        case .squeezeGate:
            return "Applies squeezing operation"
        case .displacementGate:
            return "Displaces a state in phase space"
        case .kerrGate:
            return "Applies Kerr nonlinearity"
        case .measure:
            return "Measures photonic states"
        case .halfWavePlate:
            return "Half-wave plate for polarization manipulation"
        case .quarterWavePlate:
            return "Quarter-wave plate for polarization manipulation"
        case .permutation:
            return "Permutes modes in the circuit"
        case .polarizingBeamSplitter:
            return "Beam splitter that acts on polarization"
        case .timeDelay:
            return "Applies a time delay to a mode"
        case .unitary:
            return "Arbitrary unitary transformation"
        }
    }
    
    // Whether this element type supports parameters
    var hasParameters: Bool {
        switch self {
        case .phaseShifter, .squeezeGate, .displacementGate, .kerrGate, .beamSplitter, 
             .halfWavePlate, .quarterWavePlate, .timeDelay:
            return true
        default:
            return false
        }
    }
    
    // Whether this element is supported in Perceval
    var supportedInPerceval: Bool {
        switch self {
        case .laser, .beamSplitter, .phaseShifter, .measure, .halfWavePlate, 
             .quarterWavePlate, .permutation, .polarizingBeamSplitter, .timeDelay, .unitary:
            return true
        case .squeezeGate, .displacementGate, .kerrGate:
            return false
        }
    }
    
    // Whether this element is supported in Strawberry Fields
    var supportedInStrawberryFields: Bool {
        switch self {
        case .laser, .beamSplitter, .phaseShifter, .squeezeGate, .displacementGate, .kerrGate, .measure:
            return true
        case .halfWavePlate, .quarterWavePlate, .permutation, .polarizingBeamSplitter, .timeDelay, .unitary:
            return false
        }
    }
}

struct OpticalElement: Identifiable, Equatable {
    let id = UUID()
    let type: OpticalElementType
    var position: CGPoint
    var mode: Int  // Which optical mode (wire) this element is on
    var parameters: [String: Double] = [:]  // Parameters for the gate
    
    static func == (lhs: OpticalElement, rhs: OpticalElement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Default parameters for each gate type
    static func defaultParameters(for type: OpticalElementType) -> [String: Double] {
        switch type {
        case .phaseShifter:
            return ["phi": 0.5]  // Phase shift angle
        case .squeezeGate:
            return ["r": 0.5, "theta": 0.0]  // Squeezing parameters
        case .displacementGate:
            return ["r": 0.5, "phi": 0.0]  // Displacement parameters
        case .kerrGate:
            return ["kappa": 0.1]  // Kerr nonlinearity parameter
        case .beamSplitter:
            return ["theta": 0.5, "phi": Double.pi/4]  // Beam splitter parameters
        case .halfWavePlate:
            return ["theta": 0.0]  // Rotation angle
        case .quarterWavePlate:
            return ["theta": 0.0]  // Rotation angle
        case .timeDelay:
            return ["delay": 1.0]  // Time delay
        default:
            return [:]
        }
    }
    
    // Initialize with default parameters
    init(type: OpticalElementType, position: CGPoint, mode: Int) {
        self.type = type
        self.position = position
        self.mode = mode
        self.parameters = OpticalElement.defaultParameters(for: type)
    }
    
    // Initialize with specific parameters
    init(type: OpticalElementType, position: CGPoint, mode: Int, parameters: [String: Double]) {
        self.type = type
        self.position = position
        self.mode = mode
        self.parameters = parameters
    }
}
