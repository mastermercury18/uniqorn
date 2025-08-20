import SwiftUI

struct OpticalElementPalette: View {
    let elements = OpticalElementType.allCases
    @Binding var selectedElement: OpticalElementType?
    @State private var showingDocumentation = false
    @State private var documentationElement: OpticalElement?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Optical Elements")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(elements, id: \.self) { element in
                OpticalElementView(
                    element: OpticalElement(
                        type: element,
                        position: CGPoint(x: 0, y: 0),
                        mode: 0
                    ),
                    isPaletteItem: true,
                    onTap: {
                        selectedElement = element
                    },
                    onLongPress: {
                        documentationElement = OpticalElement(
                            type: element,
                            position: CGPoint(x: 0, y: 0),
                            mode: 0
                        )
                        showingDocumentation = true
                    }
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(width: 150)
        .background(Color(hex: "#ED4EC5").opacity(0.15))
        .sheet(isPresented: $showingDocumentation) {
            if let element = documentationElement {
                DocumentationPopup(element: element) {
                    showingDocumentation = false
                }
            }
        }
    }
}

struct OpticalElementView: View {
    let element: OpticalElement
    var isPaletteItem: Bool = false
    var onRemove: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    
    @State private var showingDocumentation = false
    
    var body: some View {
        VStack {
            Text(element.type.symbol)
                .font(.title)
            
            if isPaletteItem {
                Text(element.type.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            } else {
                Text(element.type.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: isPaletteItem ? 80 : 60, height: isPaletteItem ? 80 : 60)
        .background(Color(hex: "#F2D3ED").opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#F2D3ED"), lineWidth: isPaletteItem ? 2 : 1)
        )
        .padding(4)
        .onTapGesture {
            if let onTap = onTap {
                onTap()
            } else {
                showingDocumentation = true
            }
        }
        .onLongPressGesture {
            if let onLongPress = onLongPress {
                onLongPress()
            } else {
                showingDocumentation = true
            }
        }
        .contextMenu {
            if !isPaletteItem && onRemove != nil {
                Button("Delete", role: .destructive) {
                    onRemove?()
                }
            }
            Button("Documentation") {
                showingDocumentation = true
            }
        }
        .sheet(isPresented: $showingDocumentation) {
            DocumentationPopup(element: element) {
                showingDocumentation = false
            }
        }
    }
}
