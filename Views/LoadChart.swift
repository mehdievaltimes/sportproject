import SwiftUI
import Charts

struct LoadChart: View {
    var athlete: Athlete
    

    var body: some View {
        VStack(alignment: .leading) {
            Text("Historical Load")
                .font(.headline)
                .padding(.bottom, 10)
            
            let data = athlete.gpsSessions.suffix(365)
            
            Chart {
                // 1. Draw cycle phase background band (simplified to just show current phase on last few days for now, or extending across the window)
                if athlete.isTrackingCycle, let phase = athlete.currentCyclePhase,
                   let firstDate = data.first?.date,
                   let lastDate = data.last?.date {
                    
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
                ForEach(data) { session in
                    BarMark(
                        x: .value("Date", session.date, unit: .day),
                        y: .value("Load", session.playerLoad)
                    )
                    .foregroundStyle(Color.indigo.gradient)
                    .cornerRadius(4)
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 3600 * 24 * 60) // Show 60 days at a time, scroll for the rest
            .chartYAxis {
                AxisMarks(position: .leading)
            }
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
