import SwiftUI

struct AthleteDetailView: View {
    var athlete: Athlete
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(athlete.name)
                            .font(.system(size: 36, weight: .bold))
                        Text(athlete.position)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Cycle Phase badge
                    if athlete.isTrackingCycle, let phase = athlete.currentCyclePhase {
                        VStack {
                            Text("Current Phase")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(phase.rawValue)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.pink.opacity(0.2))
                                .foregroundColor(.pink)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Key Metrics
                HStack(spacing: 20) {
                    MetricCard(title: "Acute Load (7d)", value: String(format: "%.0f", athlete.acuteLoad), unit: "AU")
                    if let latestLoad = athlete.dailyLoads.last {
                        MetricCard(title: "Latest RPE", value: "\(latestLoad.rpe ?? 0)", unit: "/ 10")
                        MetricCard(title: "Sleep", value: String(format: "%.1f", latestLoad.sleepDuration ?? 0), unit: "hrs")
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Insights / Alert Panel
                AlertPanel(alerts: RecoveryEngine.shared.evaluate(athlete: athlete))
                    .padding(.bottom, 20)
                
                // Load Chart
                Text("7-Day Load & Cycle Phase")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LoadChart(athlete: athlete)
                    .frame(height: 300)
                    .padding()
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(30)
        }
        .navigationTitle(athlete.name)
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                Text(unit)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
