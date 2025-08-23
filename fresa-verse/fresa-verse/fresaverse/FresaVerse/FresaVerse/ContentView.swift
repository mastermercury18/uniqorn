//
//  ContentView.swift
//  FresaVerse
//
//  Created by Neha Chandran on 8/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var circuit = OpticalCircuit()
    @State private var selectedFramework: QuantumFramework = .strawberryFields
    
    var body: some View {
        CircuitView(circuit: circuit, selectedFramework: $selectedFramework)
            .environmentObject(circuit)
    }
}

#Preview {
    ContentView()
}
