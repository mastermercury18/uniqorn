import Foundation
import SwiftUI

class PythonBackend: ObservableObject {
    @Published var isRunning = false
    @Published var results: [String: Any] = [:]
    @Published var error: String?
    
    func runSimulation(circuit: OpticalCircuit, framework: QuantumFramework) {
        // Run the actual Python code
        runPythonExecution(circuit: circuit, framework: framework)
    }
    
    private func runPythonExecution(circuit: OpticalCircuit, framework: QuantumFramework) {
        isRunning = true
        error = nil
        results = [:]
        
        // Generate the code
        let code = circuit.generateCode(for: framework)
        
        // Run the code in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self.executePythonCode(code, framework: framework)
                
                DispatchQueue.main.async {
                    self.results = result
                    self.isRunning = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isRunning = false
                }
            }
        }
    }
    
    private func executePythonCode(_ code: String, framework: QuantumFramework) throws -> [String: Any] {
        // Create a temporary file with the code
        let tempDir = NSTemporaryDirectory()
        let codeFile = tempDir.appending("quantum_circuit_\(UUID().uuidString).py")
        
        // Write the code to the temporary file
        try code.write(toFile: codeFile, atomically: true, encoding: .utf8)
        
        // Determine which runner script to use
        let scriptName: String
        switch framework {
        case .strawberryFields:
            scriptName = "strawberry_runner.py"
        case .perceval:
            scriptName = "perceval_runner.py"
        }
        
        // Get the path to the runner script
        guard let scriptPath = Bundle.main.path(forResource: scriptName.replacingOccurrences(of: ".py", with: ""), ofType: "py") else {
            throw NSError(domain: "PythonBackend", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find \(scriptName)"])
        }
        
        // Build the command to run the script with the code file as an argument
        let command = "python3 \"\(scriptPath)\" -f \"\(codeFile)\""
        
        // Execute the command
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        
        task.launch()
        task.waitUntilExit()
        
        // Read the output
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        // Clean up temporary file
        try? FileManager.default.removeItem(atPath: codeFile)
        
        // Parse the JSON output
        if let data = output.data(using: .utf8) {
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return result
                }
            } catch {
                // If JSON parsing fails, return the output as an error
                return [
                    "success": false,
                    "error": "Failed to parse Python output: \(output)"
                ]
            }
        }
        
        // If we get here, there was no output or it wasn't valid JSON
        return [
            "success": false,
            "error": "No valid output from Python script: \(output)"
        ]
    }
}