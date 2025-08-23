import SwiftUI

struct ParameterEditorView: View {
    let elementType: OpticalElementType
    @Binding var parameters: [String: Double]
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Parameters for \(elementType.rawValue)")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(parameterKeys(for: elementType), id: \.self) { key in
                    HStack {
                        Text(parameterDisplayName(key))
                            .frame(width: 120, alignment: .leading)
                        
                        TextField("Value", value: Binding(
                            get: { parameters[key] ?? defaultValue(for: key, in: elementType) },
                            set: { newValue in
                                parameters[key] = newValue
                            }
                        ), formatter: FloatingPointFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    }
                }
            }
            .padding()
            .background(Color(hex: "#ED4EC5").opacity(0.9))
            .cornerRadius(8)
            
            HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#ED4EC5").opacity(0.9))
                    
                    Spacer()
                    
                    Button("Save") {
                        onSave()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#ED4EC5").opacity(0.9))
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
        .background(Color(hex: "#ED4EC5").opacity(0.5)) // light pink card background
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private func parameterKeys(for type: OpticalElementType) -> [String] {
        switch type {
        case .phaseShifter:
            return ["phi"]
        case .squeezeGate:
            return ["r", "theta"]
        case .displacementGate:
            return ["r", "phi"]
        case .kerrGate:
            return ["kappa"]
        case .beamSplitter:
            return ["theta", "phi"]
        case .halfWavePlate, .quarterWavePlate:
            return ["theta"]
        case .timeDelay:
            return ["delay"]
        default:
            return []
        }
    }
    
    private func parameterDisplayName(_ key: String) -> String {
        switch key {
        case "phi":
            return "Phase (𝜙)"
        case "r":
            return "Amplitude (r)"
        case "theta":
            return "Angle (θ)"
        case "kappa":
            return "Kerr Parameter (κ)"
        case "delay":
            return "Delay"
        default:
            return key
        }
    }
    
    private func defaultValue(for key: String, in type: OpticalElementType) -> Double {
        switch type {
        case .phaseShifter:
            return key == "phi" ? 0.5 : 0.0
        case .squeezeGate:
            return key == "r" ? 0.5 : (key == "theta" ? 0.0 : 0.0)
        case .displacementGate:
            return key == "r" ? 0.5 : (key == "phi" ? 0.0 : 0.0)
        case .kerrGate:
            return key == "kappa" ? 0.1 : 0.0
        case .beamSplitter:
            return key == "theta" ? 0.5 : (key == "phi" ? Double.pi/4 : 0.0)
        case .halfWavePlate, .quarterWavePlate:
            return key == "theta" ? 0.0 : 0.0
        case .timeDelay:
            return key == "delay" ? 1.0 : 0.0
        default:
            return 0.0
        }
    }
}

// Custom formatter for floating point numbers
class FloatingPointFormatter: NumberFormatter, @unchecked Sendable {
    override init() {
        super.init()
        self.numberStyle = .decimal
        self.minimumFractionDigits = 1
        self.maximumFractionDigits = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
