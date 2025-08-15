import SwiftUI

struct OpticalElementPalette: View {
    let elements = OpticalElementType.allCases
    @Binding var selectedElement: OpticalElementType?
    
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
                    isPaletteItem: true
                )
                .onTapGesture {
                    selectedElement = element
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(width: 150)
        .background(Color.gray.opacity(0.1))
    }
}

struct OpticalElementView: View {
    let element: OpticalElement
    var isPaletteItem: Bool = false
    var onRemove: (() -> Void)? = nil
    
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
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: isPaletteItem ? 2 : 1)
        )
        .padding(4)
        .contextMenu {
            if !isPaletteItem && onRemove != nil {
                Button("Delete", role: .destructive) {
                    onRemove?()
                }
            }
        }
    }
}