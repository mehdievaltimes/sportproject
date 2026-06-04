import SwiftUI
import Charts

struct HistoricalMetricView: View {
    let title: String
    let unit: String
    let data: [MetricDataPoint]
    let color: Color
    
    var averageValue: Double {
        guard !data.isEmpty else { return 0 }
        let sum = data.reduce(0) { $0 + $1.value }
        return sum / Double(data.count)
    }
    
    var maxValue: Double {
        data.map { $0.value }.max() ?? 0
    }
    
    var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Stats
            HStack(spacing: 20) {
                StatCard(title: "Average", value: String(format: "%.1f", averageValue), unit: unit, color: color)
                StatCard(title: "Highest", value: String(format: "%.1f", maxValue), unit: unit, color: .green)
                StatCard(title: "Lowest", value: String(format: "%.1f", minValue), unit: unit, color: .red)
            }
            .padding(.horizontal)
            
            // Chart
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart {
                    // Average Line
                    RuleMark(
                        y: .value("Average", averageValue)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(color.opacity(0.5))
                    .annotation(position: .topLeading) {
                        Text("Avg: \(String(format: "%.1f", averageValue))")
                            .font(.caption2)
                            .foregroundColor(color)
                    }
                    
                    // Data Line
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(color)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(color)
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 3600 * 24 * 30) // Show 30 days initially
                .frame(height: 350)
                .padding()
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct MetricDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
