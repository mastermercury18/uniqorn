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
        print("=== DEBUG INFO ===")
        print("Generated code for \(framework.rawValue):")
        print(code)
        print("=== Code with line numbers ===")
        let lines = code.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            print("\(index + 1): \(line)")
        }
        print("=== END DEBUG INFO ===")
        
        // Run the code in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self.executePythonCodeOverHTTP(code, framework: framework)
                print("Received result: \(result)")
                
                DispatchQueue.main.async {
                    self.results = result
                    self.isRunning = false
                }
            } catch {
                print("Error executing Python code: \(error)")
                let detailedError = "Simulation failed: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    self.error = detailedError
                    self.isRunning = false
                }
            }
        }
    }
    
    private func executePythonCodeOverHTTP(_ code: String, framework: QuantumFramework) throws -> [String: Any] {
        // Determine the server URL based on the framework
        let serverURL: String
        switch framework {
        case .strawberryFields:
            serverURL = "http://localhost:8080"
        case .perceval:
            serverURL = "http://localhost:8081"
        }
        
        print("Sending request to \(serverURL)")
        
        // Create the request
        guard let url = URL(string: serverURL) else {
            let error = NSError(domain: "PythonBackend", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL: \(serverURL)"])
            print("URL error: \(error)")
            throw error
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let requestBody = ["code": code]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        // Add a timeout
        request.timeoutInterval = 30.0
        
        let requestBodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil"
        print("Request body: \(requestBodyString)")
        
        // Create a semaphore to wait for the response
        let semaphore = DispatchSemaphore(value: 0)
        var result: [String: Any] = [:]
        var requestError: Error?
        
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                print("Request error: \(error)")
                requestError = error
                return
            }
            
            // Check the HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                let error = NSError(domain: "PythonBackend", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])
                print("No data error: \(error)")
                requestError = error
                return
            }
            
            // Print the raw response data
            let responseString = String(data: data, encoding: .utf8) ?? "nil"
            print("Raw response: \(responseString)")
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON result: \(jsonResult)")
                    result = jsonResult
                    
                    // Check if the result indicates success or failure
                    if let success = jsonResult["success"] as? Bool {
                        if !success {
                            print("Server reported simulation failure")
                            // Create a more descriptive error message
                            let errorMessage = jsonResult["error"] as? String ?? "Unknown server error"
                            let error = NSError(domain: "PythonBackend", code: 5, userInfo: [NSLocalizedDescriptionKey: "Simulation failed: \(errorMessage)"])
                            requestError = error
                        }
                    } else {
                        print("Server response missing success field")
                    }
                } else {
                    let error = NSError(domain: "PythonBackend", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response from server"])
                    print("Invalid JSON error: \(error)")
                    requestError = error
                }
            } catch {
                print("JSON parsing error: \(error)")
                requestError = error
            }
        }
        
        // Start the task and wait for it to complete
        task.resume()
        semaphore.wait()
        
        // Check if there was an error during the request
        if let error = requestError {
            throw error
        }
        
        return result
    }
}