import SwiftUI
import Charts

struct LoadChart: View {
    var athlete: Athlete
    
    @State private var timeframe: Int = 28 // Default to 28 days
    
    var body: some View {
        VStack {
            HStack {
                Text("Historical Load")
                    .font(.headline)
                Spacer()
                Picker("Timeframe", selection: $timeframe) {
                    Text("7 Days").tag(7)
                    Text("28 Days").tag(28)
                    Text("60 Days").tag(60)
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
            }
            .padding(.bottom, 10)
            
            let data = athlete.dailyLoads.suffix(timeframe)
            
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
                ForEach(data) { load in
                    BarMark(
                        x: .value("Date", load.date, unit: .day),
                        y: .value("Load", load.totalLoad)
                    )
                    .foregroundStyle(Color.indigo.gradient)
                    .cornerRadius(4)
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 3600 * 24 * min(Double(timeframe), 14)) // Always show 14 days at a time, scroll for the rest
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
