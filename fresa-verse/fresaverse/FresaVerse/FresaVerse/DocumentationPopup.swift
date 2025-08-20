import SwiftUI

struct DocumentationPopup: View {
    let element: OpticalElement
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(element.type.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(element.type.description)
                        .font(.body)
                    
                    if let documentation = element.type.documentation {
                        ForEach(documentation, id: \.title) { section in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(section.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(section.content)
                                    .font(.footnote)
                                
                                if let latex = section.latex {
                                    HStack {
                                        Text(latex)
                                            .font(.system(.caption, design: .monospaced))
                                            .padding(8)
                                            .background(Color(hex: "#F2D3ED").opacity(0.3))
                                            .cornerRadius(4)
                                        
                                        CopyButton(textToCopy: latex)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .frame(width: 300, height: 350)
        .background(Color(hex: "#ED4EC5"))  // Main pink color from the app
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct DocumentationSection {
    let title: String
    let content: String
    let latex: String?
}

extension OpticalElementType {
    var documentation: [DocumentationSection]? {
        switch self {
        case .laser:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A coherent state |α⟩ is an eigenstate of the annihilation operator â with eigenvalue α.",
                    latex: "|\\(\\alpha\\rangle = e^{-|\\alpha|^2/2} \\sum_{n=0}^{\\infty} \\frac{\\alpha^n}{\\sqrt{n!}} |n\\rangle"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Coherent(α) creates a coherent state with complex displacement α.",
                    latex: "Coherent(r, \\phi) \\Rightarrow \\alpha = re^{i\\phi}"
                )
            ]
        case .beamSplitter:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A beam splitter couples two optical modes with a unitary transformation.",
                    latex: "\\hat{U}_{BS}(\\theta, \\phi) = e^{\\theta(e^{i\\phi}\\hat{a}^\\dagger\\hat{b} - e^{-i\\phi}\\hat{a}\\hat{b}^\\dagger)}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "BSgate(θ, ϕ) implements a beam splitter with transmissivity θ and phase ϕ.",
                    latex: "BSgate(\\theta, \\phi) | \\psi\\rangle"
                )
            ]
        case .phaseShifter:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A phase shifter applies a phase rotation to a mode.",
                    latex: "\\hat{U}(\\phi) = e^{i\\phi\\hat{n}} = e^{i\\phi\\hat{a}^\\dagger\\hat{a}}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Rgate(ϕ) implements a rotation gate with phase ϕ.",
                    latex: "Rgate(\\phi) | \\psi\\rangle"
                )
            ]
        case .squeezeGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A squeezing operator changes the uncertainty relation between conjugate quadratures.",
                    latex: "\\hat{S}(z) = e^{\\frac{1}{2}(z^*\\hat{a}^2 - z\\hat{a}^{\\dagger 2})}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Sgate(r, ϕ) implements a squeezing gate with squeezing parameter r and phase ϕ.",
                    latex: "Sgate(r, \\phi) | \\psi\\rangle"
                )
            ]
        case .displacementGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A displacement operator translates a state in phase space.",
                    latex: "\\hat{D}(\\alpha) = e^{\\alpha\\hat{a}^\\dagger - \\alpha^*\\hat{a}}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Dgate(r, ϕ) implements a displacement gate with displacement α = re^(iϕ).",
                    latex: "Dgate(r, \\phi) | \\psi\\rangle"
                )
            ]
        case .kerrGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "The Kerr gate applies a nonlinear phase shift proportional to the photon number squared.",
                    latex: "\\hat{K}(\\kappa) = e^{i\\kappa\\hat{n}^2}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Kgate(κ) implements a Kerr gate with Kerr parameter κ.",
                    latex: "Kgate(\\kappa) | \\psi\\rangle"
                )
            ]
        case .measure:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "Photon number measurement projects the state onto Fock states.",
                    latex: "\\hat{\\Pi}_n = |n\\rangle\\langle n|"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "MeasureFock() measures the photon number in the Fock basis.",
                    latex: "\\langle n | \\psi \\rangle"
                )
            ]
        }
    }
}