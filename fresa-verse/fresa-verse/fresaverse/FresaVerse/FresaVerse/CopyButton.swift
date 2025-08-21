import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct CopyButton: View {
    let textToCopy: String
    @State private var isCopied = false
    
    var body: some View {
        Button(action: {
            copyToClipboard(textToCopy)
            isCopied = true
            
            // Reset the button after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        }) {
            HStack {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                Text(isCopied ? "Copied!" : "Copy")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "#FACDF0").opacity(0.5))
            .foregroundColor(.primary)
            .cornerRadius(4)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}