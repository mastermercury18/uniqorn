//
//  ContentView.swift
//  FresaVerse
//
//  Created by Neha Chandran on 8/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var circuit = OpticalCircuit()
    
    var body: some View {
        CircuitView(circuit: circuit)
    }
}

#Preview {
    ContentView()
}
