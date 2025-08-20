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
                if let probabilities = results["probabilities"] as? [String: Double] {
                    ProbabilityChartView(probabilities: probabilities)
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Probabilities")
                        }
                }
                
                // Counts tab
                if let counts = results["counts"] as? [String: Int] {
                    CountsChartView(counts: counts)
                        .tabItem {
                            Image(systemName: "number")
                            Text("Counts")
                        }
                }
                
                // Photon detections tab
                if let photonDetections = results["photon_detections"] as? [String: Double] {
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
            .frame(minWidth: CGFloat(probabilities.count) * 50)
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
            .frame(minWidth: CGFloat(counts.count) * 50)
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
            .frame(minWidth: CGFloat(detections.count) * 50)
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
            
            if let simTime = results["simulation_time"] as? String {
                HStack {
                    Text("Simulation Time:")
                        .fontWeight(.bold)
                    Text(simTime)
                }
            }
            
            if let probabilities = results["probabilities"] as? [String: Double] {
                HStack {
                    Text("Number of States:")
                        .fontWeight(.bold)
                    Text("\(probabilities.count)")
                }
            }
            
            Spacer()
        }
        .padding()
    }
}