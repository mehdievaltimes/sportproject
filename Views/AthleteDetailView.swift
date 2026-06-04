import SwiftUI

struct AthleteDetailView: View {
    @Binding var athlete: Athlete
    @State private var isLoggingData = false
    @State private var isUpdatingStatus = false
    
    // Dynamic Chart State
    @State private var selectedChartCategory: String? = nil
    @State private var selectedChartTitle: String = ""
    @State private var selectedChartUnit: String = ""
    @State private var selectedChartColor: Color = .indigo
    @State private var selectedChartData: [MetricDataPoint] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(athlete.name)
                            .font(.system(size: 36, weight: .bold))
                        
                        HStack(alignment: .center, spacing: 10) {
                            Text(athlete.positions.joined(separator: ", "))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            if let h = athlete.height, let w = athlete.weight {
                                Text("\(String(format: "%.1f", h)) cm | \(String(format: "%.1f", w)) kg")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Medical Status Banner
                            if athlete.status != .available {
                                Text(athlete.status.rawValue.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(athlete.status == .injured ? Color.red.opacity(0.2) : Color.yellow.opacity(0.2))
                                    .foregroundColor(athlete.status == .injured ? .red : .orange)
                                    .clipShape(Capsule())
                            }
                            
                            Button(action: { isUpdatingStatus = true }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
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
                
                // --- PRESCRIPTIVE ANALYTICS ---
                CapacityGaugeView(athlete: athlete)
                    .padding(.bottom, 10)
                
                Divider().padding(.bottom, 10)
                
                // --- CARDS SECTION ---
                
                // Key Metrics
                HStack(spacing: 20) {
                    MetricCard(title: "Acute Load (7d)", value: String(format: "%.0f", athlete.acuteLoad), averageValue: nil, unit: "AU")
                        .onAppear {
                            // Set initial chart data
                            if !athlete.gpsSessions.isEmpty {
                                setChart("Key", "Player Load", "AU", .indigo, recentGPSData(for: \.playerLoad))
                            }
                        }
                    if let latestSession = athlete.gpsSessions.last {
                        let data = recentGPSData(for: \.playerLoad)
                        Button(action: { setChart("Key", "Player Load", "AU", .indigo, data) }) {
                            MetricCard(title: "Latest Player Load", value: String(format: "%.0f", latestSession.playerLoad), averageValue: String(format: "%.0f", average(of: data)), unit: "AU")
                        }.buttonStyle(.plain)
                    }
                    if let latestHealth = athlete.healthMetrics.last {
                        // Sleep Card with breakdown if available
                        let sleepData = recentHealthData(for: \.sleepTotalDuration)
                        Button(action: { setChart("Key", "Sleep Duration", "hrs", .purple, sleepData) }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sleep")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(String(format: "%.1f", latestHealth.sleepTotalDuration ?? 0))
                                        .font(.system(size: 28, weight: .bold))
                                    Text("hrs")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                Text("Avg: \(String(format: "%.1f", average(of: sleepData))) hrs")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                if let deep = latestHealth.sleepDeep, let rem = latestHealth.sleepRem {
                                    Text(String(format: "Deep: %.1fh | REM: %.1fh", deep, rem))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(12)
                        }.buttonStyle(.plain)
                    }
                }
                
                if selectedChartCategory == "Key" {
                    embeddedChart()
                }
                
                // GPS Advanced Metrics Grid
                if let latestSession = athlete.gpsSessions.last {
                    Text("Latest GPS Metrics")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        let maxSpeedData = recentGPSData(for: \.maxSpeed)
                        Button(action: { setChart("GPS", "Max Speed", "m/s", .yellow, maxSpeedData) }) {
                            SmallMetricCard(title: "Max Speed", value: String(format: "%.1f", latestSession.maxSpeed), averageValue: String(format: "%.1f", average(of: maxSpeedData)), unit: "m/s", icon: "bolt.fill", color: .yellow)
                        }.buttonStyle(.plain)
                        
                        let hsrData = recentGPSData(for: \.highSpeedRunningDistance)
                        Button(action: { setChart("GPS", "High Speed Running", "m", .green, hsrData) }) {
                            SmallMetricCard(title: "HSR", value: String(format: "%.0f", latestSession.highSpeedRunningDistance), averageValue: String(format: "%.0f", average(of: hsrData)), unit: "m", icon: "figure.run", color: .green)
                        }.buttonStyle(.plain)
                        
                        let sprintData = recentGPSData(for: \.sprintDistance)
                        Button(action: { setChart("GPS", "Sprint Distance", "m", .purple, sprintData) }) {
                            SmallMetricCard(title: "Sprint Dist", value: String(format: "%.0f", latestSession.sprintDistance), averageValue: String(format: "%.0f", average(of: sprintData)), unit: "m", icon: "figure.track.and.field", color: .purple)
                        }.buttonStyle(.plain)
                        
                        let metPowerData = recentGPSData(for: \.metabolicPower)
                        Button(action: { setChart("GPS", "Metabolic Power", "W/kg", .red, metPowerData) }) {
                            SmallMetricCard(title: "Metabolic Pwr", value: String(format: "%.1f", latestSession.metabolicPower), averageValue: String(format: "%.1f", average(of: metPowerData)), unit: "W/kg", icon: "flame.fill", color: .red)
                        }.buttonStyle(.plain)
                        
                        let hmldData = recentGPSData(for: \.highMetabolicLoadDistance)
                        Button(action: { setChart("GPS", "HMLD", "m", .orange, hmldData) }) {
                            SmallMetricCard(title: "HMLD", value: String(format: "%.0f", latestSession.highMetabolicLoadDistance), averageValue: String(format: "%.0f", average(of: hmldData)), unit: "m", icon: "arrow.up.right.circle.fill", color: .orange)
                        }.buttonStyle(.plain)
                        
                        let accelData = recentGPSData(for: \.accelerationsTotal).map { MetricDataPoint(date: $0.date, value: Double($0.value)) }
                        Button(action: { setChart("GPS", "Accelerations", "count", .blue, accelData) }) {
                            SmallMetricCard(title: "Accel/Decel", value: "\(latestSession.accelerationsHighIntensity) / \(latestSession.decelerationsHighIntensity)", averageValue: nil, unit: "HI", icon: "arrow.up.arrow.down", color: .blue)
                        }.buttonStyle(.plain)
                    }
                    
                    if selectedChartCategory == "GPS" {
                        embeddedChart()
                    }
                }
                
                // HealthKit Vitals Grid
                if let latestHealth = athlete.healthMetrics.last {
                    Text("Latest HealthKit Vitals")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        let vo2Data = recentHealthData(for: \.vo2Max)
                        Button(action: { setChart("Health", "VO₂ Max", "mL/kg/min", .red, vo2Data) }) {
                            SmallMetricCard(title: "VO₂ Max", value: String(format: "%.1f", latestHealth.vo2Max ?? 0), averageValue: String(format: "%.1f", average(of: vo2Data)), unit: "mL/kg/min", icon: "heart.fill", color: .red)
                        }.buttonStyle(.plain)
                        
                        let spo2Data = recentHealthData(for: \.spO2).map { MetricDataPoint(date: $0.date, value: $0.value * 100) }
                        Button(action: { setChart("Health", "SpO₂", "%", .blue, spo2Data) }) {
                            SmallMetricCard(title: "SpO₂", value: String(format: "%.1f", (latestHealth.spO2 ?? 0) * 100), averageValue: String(format: "%.1f", average(of: spo2Data)), unit: "%", icon: "lungs.fill", color: .blue)
                        }.buttonStyle(.plain)
                        
                        let respData = recentHealthData(for: \.respiratoryRate)
                        Button(action: { setChart("Health", "Respiratory Rate", "br/min", .teal, respData) }) {
                            SmallMetricCard(title: "Resp Rate", value: String(format: "%.1f", latestHealth.respiratoryRate ?? 0), averageValue: String(format: "%.1f", average(of: respData)), unit: "br/min", icon: "wind", color: .teal)
                        }.buttonStyle(.plain)
                        
                        let rhrData = recentHealthData(for: \.restingHR)
                        Button(action: { setChart("Health", "Resting HR", "bpm", .red, rhrData) }) {
                            SmallMetricCard(title: "Resting HR", value: String(format: "%.0f", latestHealth.restingHR ?? 0), averageValue: String(format: "%.0f", average(of: rhrData)), unit: "bpm", icon: "waveform.path.ecg", color: .red)
                        }.buttonStyle(.plain)
                        
                        let hrvData = recentHealthData(for: \.hrv)
                        Button(action: { setChart("Health", "HRV", "ms", .orange, hrvData) }) {
                            SmallMetricCard(title: "HRV", value: String(format: "%.0f", latestHealth.hrv ?? 0), averageValue: String(format: "%.0f", average(of: hrvData)), unit: "ms", icon: "bolt.heart.fill", color: .orange)
                        }.buttonStyle(.plain)
                        
                        if let bbt = latestHealth.basalBodyTemp {
                            let bbtData = recentHealthData(for: \.basalBodyTemp)
                            Button(action: { setChart("Health", "Basal Body Temp", "°C", .pink, bbtData) }) {
                                SmallMetricCard(title: "BBT", value: String(format: "%.2f", bbt), averageValue: String(format: "%.2f", average(of: bbtData)), unit: "°C", icon: "thermometer", color: .pink)
                            }.buttonStyle(.plain)
                        }
                    }
                    
                    if selectedChartCategory == "Health" {
                        embeddedChart()
                    }
                }
                
                // Menstrual Cycle & Readiness Panel
                if athlete.isTrackingCycle, let latestLog = athlete.cycleLogs.last {
                    Text("Cycle & Readiness")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                    
                    HStack(spacing: 16) {
                        let readinessData = recentCycleData(for: \.readinessScore)
                        Button(action: { setChart("Cycle", "Readiness Score", "/ 10", .green, readinessData) }) {
                            SmallMetricCard(title: "Readiness", value: "\(latestLog.readinessScore)", averageValue: String(format: "%.1f", average(of: readinessData)), unit: "/ 10", icon: "battery.100", color: .green)
                        }.buttonStyle(.plain)
                        
                        let symptomsData = recentCycleData(for: \.symptoms)
                        Button(action: { setChart("Cycle", "Symptoms Severity", "/ 5", .orange, symptomsData) }) {
                            SmallMetricCard(title: "Symptoms", value: "\(latestLog.symptoms)", averageValue: String(format: "%.1f", average(of: symptomsData)), unit: "/ 5", icon: "bandage.fill", color: .orange)
                        }.buttonStyle(.plain)
                        
                        let flowData = recentCycleData(for: \.flowIntensity)
                        Button(action: { setChart("Cycle", "Flow Intensity", "/ 5", .red, flowData) }) {
                            SmallMetricCard(title: "Flow", value: "\(latestLog.flowIntensity)", averageValue: String(format: "%.1f", average(of: flowData)), unit: "/ 5", icon: "drop.fill", color: .red)
                        }.buttonStyle(.plain)
                    }
                    
                    if selectedChartCategory == "Cycle" {
                        embeddedChart()
                    }
                }
                
                // Medical & Rehab Panel
                if !athlete.injuries.isEmpty {
                    Divider().padding(.vertical)
                    
                    Text("Medical & Rehab")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(athlete.injuries) { injury in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(injury.bodyPart)
                                        .font(.headline)
                                    Text("Status: \(injury.clearanceStatus ?? "Evaluating")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    if let returnDate = injury.expectedReturnDate {
                                        Text("Exp. Return")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(returnDate, style: .date)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Insights / Alert Panel
                AlertPanel(alerts: RecoveryEngine.shared.evaluate(athlete: athlete))
                    .padding(.bottom, 20)
                    
                // Clinical Notes
                NotesSection(athlete: $athlete)
            }
            .padding(30)
        }
        .navigationTitle(athlete.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isLoggingData = true }) {
                    Label("Log Data", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $isLoggingData) {
            LogDataView(athlete: $athlete)
        }
        .sheet(isPresented: $isUpdatingStatus) {
            UpdateStatusView(athlete: $athlete)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func embeddedChart() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(selectedChartTitle) History")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    withAnimation {
                        selectedChartCategory = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            HistoricalMetricView(
                title: selectedChartTitle,
                unit: selectedChartUnit,
                data: selectedChartData,
                color: selectedChartColor
            )
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(16)
        .padding(.top, 8)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Actions
    
    private func setChart(_ category: String, _ title: String, _ unit: String, _ color: Color, _ data: [MetricDataPoint]) {
        withAnimation {
            // If they click the same category, update it. If they click a different one, open it.
            selectedChartCategory = category
            selectedChartTitle = title
            selectedChartUnit = unit
            selectedChartColor = color
            selectedChartData = data
        }
    }
    
    // MARK: - Data Helpers
    
    private func recentGPSData(for keyPath: KeyPath<GPSSession, Double>) -> [MetricDataPoint] {
        let recent = athlete.gpsSessions.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -60, to: Date())! }
        return recent.map { MetricDataPoint(date: $0.date, value: $0[keyPath: keyPath]) }
    }
    
    private func recentGPSData(for keyPath: KeyPath<GPSSession, Int>) -> [MetricDataPoint] {
        let recent = athlete.gpsSessions.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -60, to: Date())! }
        return recent.map { MetricDataPoint(date: $0.date, value: Double($0[keyPath: keyPath])) }
    }

    private func recentHealthData(for keyPath: KeyPath<HealthMetric, Double?>) -> [MetricDataPoint] {
        let recent = athlete.healthMetrics.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -60, to: Date())! }
        return recent.compactMap { metric in
            if let val = metric[keyPath: keyPath] {
                return MetricDataPoint(date: metric.date, value: val)
            }
            return nil
        }
    }
    
    private func recentCycleData(for keyPath: KeyPath<CycleLog, Int>) -> [MetricDataPoint] {
        let recent = athlete.cycleLogs.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -60, to: Date())! }
        return recent.map { MetricDataPoint(date: $0.date, value: Double($0[keyPath: keyPath])) }
    }
    
    private func average(of data: [MetricDataPoint]) -> Double {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.value } / Double(data.count)
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var averageValue: String?
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
            if let avg = averageValue {
                Text("Avg: \(avg) \(unit)")
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

struct SmallMetricCard: View {
    var title: String
    var value: String
    var averageValue: String?
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
                if let avg = averageValue {
                    Text("Avg: \(avg)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
