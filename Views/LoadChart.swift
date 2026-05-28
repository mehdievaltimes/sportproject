import SwiftUI
import Charts

struct LoadChart: View {
    var athlete: Athlete
    
    var body: some View {
        Chart {
            // 1. Draw cycle phase background band
            // For MVP, simulating the current phase spanning the whole 7 days on chart
            if let phase = athlete.currentCyclePhase, 
               let firstDate = athlete.dailyLoads.suffix(7).first?.date, 
               let lastDate = athlete.dailyLoads.last?.date {
                
                RectangleMark(
                    xStart: .value("Start", firstDate),
                    xEnd: .value("End", lastDate)
                )
                .foregroundStyle(color(for: phase).opacity(0.1))
                .annotation(position: .topLeading) {
                    Text(phase.rawValue)
                        .font(.caption)
                        .foregroundColor(color(for: phase))
                        .padding(4)
                }
            }
            
            // 2. Draw the load bars
            ForEach(athlete.dailyLoads.suffix(7)) { load in
                BarMark(
                    x: .value("Date", load.date, unit: .day),
                    y: .value("Load", load.totalLoad)
                )
                .foregroundStyle(Color.indigo.gradient)
                .cornerRadius(4)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    func color(for phase: CyclePhase?) -> Color {
        switch phase {
        case .menstrual: return .red
        case .follicular: return .blue
        case .ovulatory: return .green
        case .luteal: return .orange
        case .none: return .clear
        }
    }
}
