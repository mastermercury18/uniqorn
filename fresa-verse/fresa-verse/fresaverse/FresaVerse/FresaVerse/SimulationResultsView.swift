import SwiftUI
import Charts

struct SimulationResultsView: View {
    let results: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Simulation Results")
                .font(.headline)
            
            // Tab view for different result types
            TabView {
                // Probabilities tab
                if let probabilities = extractProbabilities() {
                    ProbabilityChartView(probabilities: probabilities)
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Probabilities")
                        }
                }
                
                // Counts tab
                if let counts = extractCounts() {
                    CountsChartView(counts: counts)
                        .tabItem {
                            Image(systemName: "number")
                            Text("Counts")
                        }
                }
                
                // Photon detections tab
                if let photonDetections = extractPhotonDetections() {
                    PhotonDetectionsChartView(detections: photonDetections)
                        .tabItem {
                            Image(systemName: "eye")
                            Text("Photon Detections")
                        }
                }
                
                // Simulation info tab
                SimulationInfoView(results: results)
                    .tabItem {
                        Image(systemName: "info.circle")
                        Text("Simulation Info")
                    }
            }
            .frame(height: 300)
        }
        .padding()
        .background(Color(hex: "#F2D3ED").opacity(0.5))
        .cornerRadius(8)
    }
    
    // Helper function to extract probabilities from different data types
    private func extractProbabilities() -> [String: Double]? {
        // Try to get probabilities directly from results
        if let probabilities = results["probabilities"] as? [String: Double] {
            return probabilities
        }
        
        // Try to get from nested results object
        if let resultsObj = results["results"] as? [String: Any],
           let probabilities = resultsObj["probabilities"] as? [String: Double] {
            return probabilities
        }
        
        // Try to parse string representations
        if let resultsObj = results["results"] as? [String: Any],
           let probabilitiesStr = resultsObj["probabilities"] as? String {
            return parseStringToDictionary(probabilitiesStr)
        }
        
        return nil
    }
    
    // Helper function to extract counts from different data types
    private func extractCounts() -> [String: Int]? {
        // Try to get counts directly from results
        if let counts = results["counts"] as? [String: Int] {
            return counts
        }
        
        // Try to get from nested results object
        if let resultsObj = results["results"] as? [String: Any],
           let counts = resultsObj["counts"] as? [String: Int] {
            return counts
        }
        
        // Try to parse string representations
        if let resultsObj = results["results"] as? [String: Any],
           let countsStr = resultsObj["counts"] as? String {
            return parseStringToIntDictionary(countsStr)
        }
        
        // Generate counts from probabilities if available
        if let probabilities = extractProbabilities() {
            return generateCountsFromProbabilities(probabilities)
        }
        
        return nil
    }
    
    // Helper function to extract photon detections
    private func extractPhotonDetections() -> [String: Double]? {
        // Try to get photon detections directly from results
        if let photonDetections = results["photon_detections"] as? [String: Double] {
            return photonDetections
        }
        
        // Try to get from nested results object
        if let resultsObj = results["results"] as? [String: Any],
           let photonDetections = resultsObj["photon_detections"] as? [String: Double] {
            return photonDetections
        }
        
        // Try to parse string representations
        if let resultsObj = results["results"] as? [String: Any],
           let detectionsStr = resultsObj["photon_detections"] as? String {
            return parseStringToDictionary(detectionsStr)
        }
        
        return nil
    }
    
    // Generate counts from probabilities
    private func generateCountsFromProbabilities(_ probabilities: [String: Double]) -> [String: Int] {
        var counts: [String: Int] = [:]
        let totalSamples = 1000
        
        for (state, probability) in probabilities {
            let count = Int(probability * Double(totalSamples))
            if count > 0 {
                counts[state] = count
            }
        }
        
        return counts
    }
    
    // Parse string representation of dictionary to [String: Double]
    private func parseStringToDictionary(_ str: String) -> [String: Double]? {
        // Handle Python dict format: {'00': 0.25, '01': 0.25}
        let cleanStr = str.replacingOccurrences(of: "'", with: "\"")
            .replacingOccurrences(of: "OrderedDict", with: "")
            .replacingOccurrences(of: "dict", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse as JSON
        if let data = cleanStr.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    var result: [String: Double] = [:]
                    for (key, value) in dict {
                        if let doubleValue = value as? Double {
                            result[key] = doubleValue
                        } else if let intValue = value as? Int {
                            result[key] = Double(intValue)
                        } else if let stringValue = value as? String, let doubleValue = Double(stringValue) {
                            result[key] = doubleValue
                        }
                    }
                    return result
                }
            } catch {
                print("Error parsing dictionary string: \(error)")
            }
        }
        
        return nil
    }
    
    // Parse string representation of dictionary to [String: Int]
    private func parseStringToIntDictionary(_ str: String) -> [String: Int]? {
        // Handle Python dict format: {'00': 250, '01': 250}
        let cleanStr = str.replacingOccurrences(of: "'", with: "\"")
            .replacingOccurrences(of: "OrderedDict", with: "")
            .replacingOccurrences(of: "dict", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse as JSON
        if let data = cleanStr.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    var result: [String: Int] = [:]
                    for (key, value) in dict {
                        if let intValue = value as? Int {
                            result[key] = intValue
                        } else if let doubleValue = value as? Double {
                            result[key] = Int(doubleValue)
                        } else if let stringValue = value as? String, let intValue = Int(stringValue) {
                            result[key] = intValue
                        }
                    }
                    return result
                }
            } catch {
                print("Error parsing integer dictionary string: \(error)")
            }
        }
        
        return nil
    }
}

struct ProbabilityChartView: View {
    let probabilities: [String: Double]
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(probabilities.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    BarMark(
                        x: .value("State", key),
                        y: .value("Probability", value)
                    )
                    .foregroundStyle(Color(hex: "#ED4EC5"))
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended)
            }
            .chartXAxis {
                AxisMarks(preset: .extended) { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .frame(minWidth: max(CGFloat(probabilities.count) * 50, 300))
        }
    }
}

struct CountsChartView: View {
    let counts: [String: Int]
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(counts.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    BarMark(
                        x: .value("State", key),
                        y: .value("Counts", Double(value))
                    )
                    .foregroundStyle(Color(hex: "#FACDF0"))
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended)
            }
            .chartXAxis {
                AxisMarks(preset: .extended) { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .frame(minWidth: max(CGFloat(counts.count) * 50, 300))
        }
    }
}

struct PhotonDetectionsChartView: View {
    let detections: [String: Double]
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(detections.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    BarMark(
                        x: .value("Mode", key),
                        y: .value("Detection Probability", value)
                    )
                    .foregroundStyle(Color(hex: "#F2A2CD"))
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended)
            }
            .chartXAxis {
                AxisMarks(preset: .extended) { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .frame(minWidth: max(CGFloat(detections.count) * 50, 300))
        }
    }
}

struct SimulationInfoView: View {
    let results: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let success = results["success"] as? Bool {
                HStack {
                    Text("Status:")
                        .fontWeight(.bold)
                    Text(success ? "Success" : "Failed")
                        .foregroundColor(success ? .green : .red)
                }
            }
            
            if let resultsObj = results["results"] as? [String: Any] {
                if let simTime = resultsObj["simulation_time"] as? String {
                    HStack {
                        Text("Simulation Time:")
                            .fontWeight(.bold)
                        Text(simTime)
                    }
                }
                
                if let probabilities = resultsObj["probabilities"] as? [String: Double] {
                    HStack {
                        Text("Number of States:")
                            .fontWeight(.bold)
                        Text("\(probabilities.count)")
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}