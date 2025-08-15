import SwiftUI

struct CircuitView: View {
    @ObservedObject var circuit: OpticalCircuit
    @State private var selectedElementType: OpticalElementType?
    
    var body: some View {
        VStack(spacing: 10) {
            // Toolbar
            HStack {
                Text("Optical Circuit Composer")
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
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                .help("Generate and run simulation code")
            }
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                // Palette of elements
                ScrollView {
                    OpticalElementPalette(
                        selectedElement: $selectedElementType
                    )
                }
                .frame(width: 150)
                
                // Circuit area
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
                    
                    // Mode wires
                    ScrollView([.horizontal, .vertical]) {
                        VStack(spacing: 10) {
                            ForEach(0..<circuit.modes, id: \.self) { mode in
                                ModeWireView(
                                    mode: mode, 
                                    circuit: circuit,
                                    selectedElementType: $selectedElementType,
                                    onAddElement: { elementType in
                                        let element = OpticalElement(
                                            type: elementType,
                                            position: CGPoint(x: 0, y: 0),
                                            mode: mode
                                        )
                                        circuit.addElement(element)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Results area
                    if !circuit.results.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Generated Strawberry Fields Code:")
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
                            
                            ScrollView {
                                Text(circuit.results)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    func runSimulation() {
        let code = circuit.generateStrawberryFieldsCode()
        circuit.results = code
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
                        selectedElementType != nil ? Color.green : 
                        (isTargeted ? Color.blue : Color.gray), 
                        lineWidth: selectedElementType != nil ? 3 : (isTargeted ? 2 : 1)
                    )
                    .frame(height: 60)
                    .background(
                        selectedElementType != nil ? Color.green.opacity(0.2) : 
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