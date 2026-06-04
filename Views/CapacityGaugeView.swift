import SwiftUI

struct CapacityGaugeView: View {
    var athlete: Athlete
    
    var body: some View {
        let maxLoad = AnalyticsEngine.shared.predictedMaxSafeLoad(for: athlete)
        let currentLoad = AnalyticsEngine.shared.loadToday(for: athlete)
        let acwr = AnalyticsEngine.shared.calculateACWR(for: athlete)
        
        let fraction = maxLoad > 0 ? min(currentLoad / maxLoad, 1.0) : 0
        
        // Determine Color based on ACWR
        let statusColor: Color = {
            if acwr < 0.8 { return .blue }      // Under-training
            if acwr <= 1.3 { return .green }    // Sweet Spot
            if acwr <= 1.5 { return .orange }   // Caution
            return .red                         // Danger Zone
        }()
        
        HStack(spacing: 30) {
            // Text Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Prescriptive Analytics")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .textCase(.uppercase)
                
                Text("Daily Capacity")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Based on the Acute:Chronic Workload Ratio (ACWR) of the past 28 days, this is the maximum Player Load recommended for today's session to avoid the injury danger zone.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Current ACWR")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f", acwr))
                            .font(.headline)
                            .foregroundColor(statusColor)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Max Safe Load")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f AU", maxLoad))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Custom Gauge
            ZStack {
                // Background Arc
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 150, height: 150)
                
                // Progress Arc
                Circle()
                    .trim(from: 0.5, to: 0.5 + (fraction * 0.5))
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .animation(.easeOut(duration: 1.0), value: fraction)
                
                // Labels inside Gauge
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", currentLoad))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text("Today's Load")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .offset(y: -15) // Push up slightly to center in the half-circle
            }
            .frame(width: 160, height: 90, alignment: .top) // Clip the bottom half of the circle
            .padding(.trailing, 20)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
