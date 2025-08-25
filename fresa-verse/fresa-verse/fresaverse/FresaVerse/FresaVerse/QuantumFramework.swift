import Foundation

enum QuantumFramework: String, CaseIterable, Identifiable {
    case strawberryFields = "strawberryfields"
    case perceval = "perceval"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .strawberryFields:
            return "Strawberry Fields"
        case .perceval:
            return "Perceval"
        }
    }
}