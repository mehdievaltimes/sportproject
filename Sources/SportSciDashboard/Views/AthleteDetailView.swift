import SwiftUI

struct AthleteDetailView: View {
    @Binding var athlete: Athlete
    
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
                .padding(.bottom, 10)
                
                // Key Metrics
                HStack(spacing: 20) {
                    MetricCard(title: "Acute Load (7d)", value: String(format: "%.0f", athlete.acuteLoad), unit: "AU")
                    if let latestLoad = athlete.dailyLoads.last {
                        MetricCard(title: "Latest RPE", value: "\(latestLoad.rpe ?? 0)", unit: "/ 10")
                        
                        // Sleep Card with breakdown if available
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sleep")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", latestLoad.sleepDuration ?? 0))
                                    .font(.system(size: 28, weight: .bold))
                                Text("hrs")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            if let deep = latestLoad.sleepDeep, let rem = latestLoad.sleepRem {
                                Text(String(format: "Deep: %.1fh | REM: %.1fh", deep, rem))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(12)
                    }
                }
                
                // HealthKit Vitals Grid
                if let latestLoad = athlete.dailyLoads.last {
                    Text("Latest HealthKit Vitals")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        SmallMetricCard(title: "VO₂ Max", value: String(format: "%.1f", latestLoad.vo2Max ?? 0), unit: "mL/kg/min", icon: "heart.fill", color: .red)
                        SmallMetricCard(title: "SpO₂", value: String(format: "%.1f", (latestLoad.spO2 ?? 0) * 100), unit: "%", icon: "lungs.fill", color: .blue)
                        SmallMetricCard(title: "Resp Rate", value: String(format: "%.1f", latestLoad.respiratoryRate ?? 0), unit: "br/min", icon: "wind", color: .teal)
                        SmallMetricCard(title: "Resting HR", value: String(format: "%.0f", latestLoad.restingHR ?? 0), unit: "bpm", icon: "waveform.path.ecg", color: .red)
                        SmallMetricCard(title: "HRV", value: String(format: "%.0f", latestLoad.hrv ?? 0), unit: "ms", icon: "bolt.heart.fill", color: .orange)
                        if let bbt = latestLoad.basalBodyTemp {
                            SmallMetricCard(title: "BBT", value: String(format: "%.2f", bbt), unit: "°C", icon: "thermometer", color: .pink)
                        }
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
                    
                Divider()
                    .padding(.vertical)
                    
                // Clinical Notes
                NotesSection(athlete: $athlete)
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

struct SmallMetricCard: View {
    var title: String
    var value: String
    var unit: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
