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
                    
                    // Show framework support information
                    Group {
                        if !element.type.supportedInPerceval {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Not directly supported in Perceval")
                                    .fontWeight(.semibold)
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }
                        if !element.type.supportedInStrawberryFields {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Not directly supported in Strawberry Fields")
                                    .fontWeight(.semibold)
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    
                    if let documentation = element.type.documentation {
                        ForEach(documentation) { section in
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

struct DocumentationSection: Identifiable {
    let id = UUID()
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
                    latex: "|\\\\(\\\\alpha\\\\rangle = e^{-|\\\\alpha|^2/2} \\\\sum_{n=0}^{\\\\infty} \\\\frac{\\\\alpha^n}{\\\\sqrt{n!}} |n\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Coherent(α) creates a coherent state with complex displacement α.",
                    latex: "Coherent(r, \\\\phi) \\\\Rightarrow \\\\alpha = re^{i\\\\phi}"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Perceval doesn't have a direct equivalent to a laser. We use single photon sources as basic inputs.",
                    latex: "pcvl.Source(emission_probability=1)"
                )
            ]
        case .beamSplitter:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A beam splitter couples two optical modes with a unitary transformation.",
                    latex: "\\\\hat{U}_{BS}(\\\\theta, \\\\phi) = e^{\\\\theta(e^{i\\\\phi}\\\\hat{a}^\\\\dagger\\\\hat{b} - e^{-i\\\\phi}\\\\hat{a}\\\\hat{b}^\\\\dagger)}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "BSgate(θ, ϕ) implements a beam splitter with transmissivity θ and phase ϕ.",
                    latex: "BSgate(\\\\theta, \\\\phi) | \\\\psi\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.BS(theta=θ, phi_bl=ϕ) implements a beam splitter with parameters θ and ϕ.",
                    latex: "pcvl.BS(theta=\\\\theta, phi_bl=\\\\phi)"
                )
            ]
        case .phaseShifter:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A phase shifter applies a phase rotation to a mode.",
                    latex: "\\\\hat{U}(\\\\phi) = e^{i\\\\phi\\\\hat{n}} = e^{i\\\\phi\\\\hat{a}^\\\\dagger\\\\hat{a}}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Rgate(ϕ) implements a rotation gate with phase ϕ.",
                    latex: "Rgate(\\\\phi) | \\\\psi\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.PS(ϕ) implements a phase shifter with phase ϕ.",
                    latex: "pcvl.PS(\\\\phi)"
                )
            ]
        case .squeezeGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A squeezing operator changes the uncertainty relation between conjugate quadratures.",
                    latex: "\\\\hat{S}(z) = e^{\\\\frac{1}{2}(z^*\\\\hat{a}^2 - z\\\\hat{a}^{\\\\dagger 2})}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Sgate(r, ϕ) implements a squeezing gate with squeezing parameter r and phase ϕ.",
                    latex: "Sgate(r, \\\\phi) | \\\\psi\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Squeezing gates are not directly supported in Perceval.",
                    latex: nil
                )
            ]
        case .displacementGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "A displacement operator translates a state in phase space.",
                    latex: "\\\\hat{D}(\\\\alpha) = e^{\\\\alpha\\\\hat{a}^\\\\dagger - \\\\alpha^*\\\\hat{a}}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Dgate(r, ϕ) implements a displacement gate with displacement α = re^(iϕ).",
                    latex: "Dgate(r, \\\\phi) | \\\\psi\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Displacement gates are not directly supported in Perceval.",
                    latex: nil
                )
            ]
        case .kerrGate:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "The Kerr gate applies a nonlinear phase shift proportional to the photon number squared.",
                    latex: "\\\\hat{K}(\\\\kappa) = e^{i\\\\kappa\\\\hat{n}^2}"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "Kgate(κ) implements a Kerr gate with Kerr parameter κ.",
                    latex: "Kgate(\\\\kappa) | \\\\psi\\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Kerr gates are not directly supported in Perceval.",
                    latex: nil
                )
            ]
        case .measure:
            return [
                DocumentationSection(
                    title: "Mathematical Representation",
                    content: "Photon number measurement projects the state onto Fock states.",
                    latex: "\\\\hat{\\\\Pi}_n = |n\\\\rangle\\\\langle n|"
                ),
                DocumentationSection(
                    title: "In Strawberry Fields",
                    content: "MeasureFock() measures the photon number in the Fock basis.",
                    latex: "\\\\langle n | \\\\psi \\\\rangle"
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Measurement is implicit in Perceval. The simulator computes probabilities for all possible outcomes.",
                    latex: "simulator.probs(input_state)"
                )
            ]
        case .halfWavePlate:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A half-wave plate (HWP) is an optical device that rotates the polarization of light by twice the angle of the plate's axis.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.HWP(θ) implements a half-wave plate with rotation angle θ.",
                    latex: "pcvl.HWP(\\\\theta)"
                )
            ]
        case .quarterWavePlate:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A quarter-wave plate (QWP) is an optical device that converts between linear and circular polarization.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.QWP(θ) implements a quarter-wave plate with rotation angle θ.",
                    latex: "pcvl.QWP(\\\\theta)"
                )
            ]
        case .permutation:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A permutation circuit reorders the modes in the optical circuit.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.PERM(perm_list) implements a permutation of modes according to the permutation list.",
                    latex: "pcvl.PERM([1, 0, 2])"
                )
            ]
        case .polarizingBeamSplitter:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A polarizing beam splitter (PBS) transmits one polarization while reflecting the orthogonal polarization.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.PBS() implements a polarizing beam splitter.",
                    latex: "pcvl.PBS()"
                )
            ]
        case .timeDelay:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A time delay component applies a temporal delay to photons in a mode.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "pcvl.TD(delay) implements a time delay with the specified delay value.",
                    latex: "pcvl.TD(delay)"
                )
            ]
        case .unitary:
            return [
                DocumentationSection(
                    title: "Description",
                    content: "A unitary component implements an arbitrary unitary transformation on the optical modes.",
                    latex: nil
                ),
                DocumentationSection(
                    title: "In Perceval",
                    content: "Unitary(matrix) implements a unitary transformation defined by the given matrix.",
                    latex: "Unitary(matrix)"
                )
            ]
        }
    }
}