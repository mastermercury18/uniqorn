import Foundation

enum OpticalElementType: String, CaseIterable {
    case laser = "Laser"
    case beamSplitter = "Beam Splitter"
    case phaseShifter = "Phase Shifter"
    case squeezeGate = "Squeezing Gate"
    case displacementGate = "Displacement Gate"
    case kerrGate = "Kerr Gate"
    case measure = "Photonic Measurement"
    
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
        }
    }
}

struct OpticalElement: Identifiable, Equatable {
    let id = UUID()
    let type: OpticalElementType
    var position: CGPoint
    var mode: Int  // Which optical mode (wire) this element is on
    
    static func == (lhs: OpticalElement, rhs: OpticalElement) -> Bool {
        return lhs.id == rhs.id
    }
}