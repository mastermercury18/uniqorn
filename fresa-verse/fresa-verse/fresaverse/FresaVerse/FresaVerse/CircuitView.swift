import SwiftUI
import CoreGraphics
import Foundation

struct CircuitView: View {
    @ObservedObject var circuit: OpticalCircuit
    @Binding var selectedFramework: QuantumFramework
    @StateObject private var pythonBackend = PythonBackend()
    @State private var selectedElementType: OpticalElementType?
    @State private var showingParameterEditor = false
    @State private var pendingElementType: OpticalElementType?
    @State private var pendingMode: Int = 0
    @State private var pendingParameters: [String: Double] = [:]
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // Toolbar
                HStack {
                    // Framework selector
                    Picker("Framework", selection: $selectedFramework) {
                        ForEach(QuantumFramework.allCases, id: \.self) { framework in
                            Text(framework.displayName)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                    
                    Text("FresaVerse: Photonic Quantum Circuit Composer 🍓🌌")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        circuit.clearCircuit()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Clear circuit")
                    
                    Button(action: {
                        runSimulation()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Run")
                        }
                        .padding(8)
                        .background(Color(hex: "#FACDF0").opacity(0.5))
                        .cornerRadius(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Generate and run simulation code")
                }
                .padding(.horizontal)
                
                // Main content area with circuit as primary focus
                HStack(spacing: 0) {
                    // Palette of elements
                    ScrollView {
                        OpticalElementPalette(
                            selectedElement: $selectedElementType,
                            selectedFramework: $selectedFramework
                        )
                    }
                    .frame(width: 150)
                    
                    // Circuit area - this is now the main focus
                    VStack {
                        // Mode controls
                        HStack {
                            Text("Modes: \(circuit.modes)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                if circuit.modes < 8 {  // Reasonable limit
                                    circuit.modes += 1
                                }
                            }) {
                                Image(systemName: "plus.circle")
                            }
                            .disabled(circuit.modes >= 8)
                            
                            Button(action: {
                                if circuit.modes > 1 {
                                    circuit.modes -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle")
                            }
                            .disabled(circuit.modes <= 1)
                        }
                        .padding(.horizontal)
                        
                        // Mode wires - main circuit area (no longer scrolls)
                        VStack(spacing: 10) {
                            ForEach(0..<circuit.modes, id: \.self) { mode in
                                ModeWireView(
                                    mode: mode, 
                                    circuit: circuit,
                                    selectedElementType: $selectedElementType,
                                    onAddElement: { elementType in
                                        // If the element has parameters, show the parameter editor first
                                        if elementType.hasParameters {
                                            pendingElementType = elementType
                                            pendingMode = mode
                                            pendingParameters = OpticalElement.defaultParameters(for: elementType)
                                            showingParameterEditor = true
                                        } else {
                                            let element = OpticalElement(
                                                type: elementType,
                                                position: CGPoint(x: 0, y: 0),
                                                mode: mode
                                            )
                                            circuit.addElement(element)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                        
                        // Results area - now in a scrollable section below the circuit
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                // Code generation section
                                if !circuit.results.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text("Generated \(selectedFramework.rawValue) Code:")
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                circuit.results = ""
                                            }) {
                                                Image(systemName: "xmark.circle")
                                                    .foregroundColor(.secondary)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                        
                                        HStack {
                                            ScrollView {
                                                Text(circuit.results)
                                                    .font(.system(.caption, design: .monospaced))
                                                    .padding()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .textSelection(.enabled)
                                            }
                                            
                                            CopyButton(textToCopy: circuit.results)
                                                .padding(.trailing, 8)
                                        }
                                        .frame(height: 200)
                                        .padding()
                                        .background(Color(hex: "#F2D3ED").opacity(0.5))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                // Python simulation results
                                if pythonBackend.isRunning {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Running simulation...")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(hex: "#F2D3ED").opacity(0.5))
                                    .cornerRadius(8)
                                } else if let error = pythonBackend.error {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle")
                                            .foregroundColor(.orange)
                                        Text("Error: \(error)")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(hex: "#F2D3ED").opacity(0.5))
                                    .cornerRadius(8)
                                } else if !pythonBackend.results.isEmpty {
                                    SimulationResultsView(results: pythonBackend.results)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)  // Add some padding at the bottom
                        }
                    }
                }
            }
            
            // Parameter editor overlay
            if showingParameterEditor, let elementType = pendingElementType {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingParameterEditor = false
                        pendingElementType = nil
                        pendingParameters = [:]
                    }
                
                ParameterEditorView(
                    elementType: elementType,
                    parameters: $pendingParameters,
                    onSave: {
                        let element = OpticalElement(
                            type: elementType,
                            position: CGPoint(x: 0, y: 0),
                            mode: pendingMode,
                            parameters: pendingParameters
                        )
                        circuit.addElement(element)
                        showingParameterEditor = false
                        pendingElementType = nil
                        pendingParameters = [:]
                    },
                    onCancel: {
                        showingParameterEditor = false
                        pendingElementType = nil
                        pendingParameters = [:]
                    }
                )
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 20)
                .frame(minWidth: 300, maxWidth: 400, minHeight: 250, maxHeight: 300)
            }
        }
    }
    
    func runSimulation() {
        // Generate the code first
        let code = circuit.generateCode(for: selectedFramework)
        circuit.results = code
        
        // Run the simulation using Python backend
        pythonBackend.runSimulation(circuit: circuit, framework: selectedFramework)
    }
}

struct ModeWireView: View {
    let mode: Int
    @ObservedObject var circuit: OpticalCircuit
    @Binding var selectedElementType: OpticalElementType?
    let onAddElement: (OpticalElementType) -> Void
    
    @State private var isTargeted = false
    
    var body: some View {
        HStack {
            Text("Mode \(mode)")
                .font(.caption)
                .frame(width: 60, alignment: .leading)
                .padding(.trailing, 5)
            
            ZStack(alignment: .leading) {
                // Wire line
                RoundedRectangle(cornerRadius: 2)
                    .stroke(
                        selectedElementType != nil ? Color(hex: "#fa43e8") :
                        (isTargeted ? Color.blue : Color.gray),
                        lineWidth: selectedElementType != nil ? 3 : (isTargeted ? 2 : 1)
                    )
                    .frame(height: 60)
                    .background(
                        selectedElementType != nil ? Color(hex: "#fa43e8").opacity(0.2) :
                        (isTargeted ? Color.blue.opacity(0.1) : Color.clear)
                    )
                    .onTapGesture {
                        if let elementType = selectedElementType {
                            onAddElement(elementType)
                        }
                    }
                
                // Elements on this mode
                HStack {
                    ForEach(circuit.elements.filter { $0.mode == mode }.sorted { $0.position.x < $1.position.x }) { element in
                        OpticalElementView(
                            element: element,
                            onRemove: {
                                circuit.removeElement(element)
                            }
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 5)
    }
}