import Foundation
import SwiftUI

class PythonBackend: ObservableObject {
    @Published var isRunning = false
    @Published var results: [String: Any] = [:]
    @Published var error: String?
    
    func runSimulation(circuit: OpticalCircuit) {
        // Simulate running the Python code
        simulatePythonExecution(circuit: circuit)
    }
    
    private func simulatePythonExecution(circuit: OpticalCircuit) {
        isRunning = true
        error = nil
        results = [:]
        
        // Simulate some processing time
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate 1-2 seconds of processing time
            Thread.sleep(forTimeInterval: Double.random(in: 1.0...2.0))
            
            // Generate simulated results
            let simulatedResults = self.generateSimulatedResults()
            
            DispatchQueue.main.async {
                self.results = simulatedResults
                self.isRunning = false
            }
        }
    }
    
    private func generateSimulatedResults() -> [String: Any] {
        // Generate realistic-looking simulation results
        let modes = Int.random(in: 2...4)
        
        // Generate probabilities for different outcomes
        var probabilities: [String: Double] = [:]
        var counts: [String: Int] = [:]
        
        // Generate all possible outcomes for the given number of modes
        let totalOutcomes = Int(pow(2.0, Double(modes)))
        var probSum: Double = 0.0
        
        for i in 0..<totalOutcomes {
            let binaryString = String(i, radix: 2).padded(toLength: modes, withPad: "0", startingAt: 0)
            let probability = Double.random(in: 0.0...1.0)
            probabilities[binaryString] = probability
            probSum += probability
        }
        
        // Normalize probabilities
        for (key, value) in probabilities {
            let normalizedProb = value / probSum
            probabilities[key] = normalizedProb
            counts[key] = Int((normalizedProb) * 1000) // Simulate 1000 shots
        }
        
        // Generate photon detection results
        var photonDetections: [String: Double] = [:]
        for i in 0..<modes {
            photonDetections["mode_\(i)"] = Double.random(in: 0.0...1.0)
        }
        
        return [
            "success": true,
            "probabilities": probabilities,
            "counts": counts,
            "photon_detections": photonDetections,
            "simulation_time": String(format: "%.3f seconds", Double.random(in: 0.1...1.5))
        ]
    }
}

// Extension to pad strings
extension String {
    func padded(toLength: Int, withPad character: Character, startingAt index: Int) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeating: character, count: toLength - newLength) + self
        } else {
            return self
        }
    }
}