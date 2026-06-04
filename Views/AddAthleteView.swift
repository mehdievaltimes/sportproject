import SwiftUI

struct AddAthleteView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("loggedInTeamDomain") private var loggedInTeamDomain = ""
    @State private var athleteManager = AthleteManager.shared
    
    @State private var name: String = ""
    @State private var position: String = ""
    @State private var heightString: String = ""
    @State private var weightString: String = ""
    @State private var isTrackingCycle: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name", text: $name)
                    TextField("Positions (comma-separated)", text: $position)
                    TextField("Height (cm)", text: $heightString)
                    TextField("Weight (kg)", text: $weightString)
                }
                
                Section(header: Text("Health Settings")) {
                    Toggle("Tracking Menstrual Cycle", isOn: $isTrackingCycle)
                }
            }
            .padding()
            .frame(width: 400, height: 250)
            .navigationTitle("Add New Athlete")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAthlete()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveAthlete() {
        let newAthlete = Athlete(
            id: UUID().uuidString,
            teamDomain: loggedInTeamDomain,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            positions: position.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            isTrackingCycle: isTrackingCycle,
            currentCyclePhase: isTrackingCycle ? .follicular : nil, // Default starting phase
            height: Double(heightString),
            weight: Double(weightString),
            gpsSessions: [],
            healthMetrics: [],
            cycleLogs: [],
            notes: [],
            status: .available,
            injuries: []
        )
        athleteManager.saveAthlete(newAthlete)
        dismiss()
    }
}
