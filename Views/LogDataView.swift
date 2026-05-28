import SwiftUI

struct LogDataView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var athlete: Athlete
    
    @State private var date: Date = Date()
    @State private var rpe: Double = 5.0
    @State private var wellnessScore: Double = 7.0
    @State private var sleepDuration: Double = 8.0
    @State private var restingHR: String = ""
    @State private var selectedPhase: CyclePhase = .follicular
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Date & Time")) {
                    DatePicker("Entry Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Subjective Metrics")) {
                    VStack {
                        HStack {
                            Text("RPE (Rating of Perceived Exertion)")
                            Spacer()
                            Text("\(Int(rpe))/10").fontWeight(.bold)
                        }
                        Slider(value: $rpe, in: 1...10, step: 1)
                    }
                    
                    VStack {
                        HStack {
                            Text("Wellness Score")
                            Spacer()
                            Text("\(Int(wellnessScore))/10").fontWeight(.bold)
                        }
                        Slider(value: $wellnessScore, in: 1...10, step: 1)
                    }
                }
                
                Section(header: Text("Vitals")) {
                    VStack {
                        HStack {
                            Text("Sleep Duration")
                            Spacer()
                            Text(String(format: "%.1f hrs", sleepDuration)).fontWeight(.bold)
                        }
                        Slider(value: $sleepDuration, in: 0...14, step: 0.5)
                    }
                    
                    TextField("Resting Heart Rate (bpm)", text: $restingHR)
                }
                
                if athlete.isTrackingCycle {
                    Section(header: Text("Cycle Phase Override")) {
                        Picker("Current Phase", selection: $selectedPhase) {
                            ForEach(CyclePhase.allCases, id: \.self) { phase in
                                Text(phase.rawValue).tag(phase)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .padding()
            .frame(width: 450, height: 500)
            .navigationTitle("Log Manual Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveData()
                    }
                }
            }
            .onAppear {
                if let currentPhase = athlete.currentCyclePhase {
                    selectedPhase = currentPhase
                }
            }
        }
    }
    
    private func saveData() {
        let rhr = Double(restingHR.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let newLoad = DailyLoad(
            id: UUID(),
            date: date,
            totalDistance: 0, // Manual logs don't imply GPS distance by default
            highSpeedDistance: 0,
            maxSpeed: 0,
            restingHR: rhr,
            sleepDuration: sleepDuration,
            rpe: Int(rpe),
            wellnessScore: Int(wellnessScore)
        )
        
        athlete.dailyLoads.append(newLoad)
        athlete.dailyLoads.sort { $0.date < $1.date }
        
        if athlete.isTrackingCycle {
            athlete.currentCyclePhase = selectedPhase
        }
        
        dismiss()
    }
}
