import SwiftUI

struct AddAthleteView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var squad: Squad
    
    @State private var name: String = ""
    @State private var position: String = ""
    @State private var isTrackingCycle: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name", text: $name)
                    TextField("Position", text: $position)
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
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            position: position.trimmingCharacters(in: .whitespacesAndNewlines),
            isTrackingCycle: isTrackingCycle,
            currentCyclePhase: isTrackingCycle ? .follicular : nil, // Default starting phase
            dailyLoads: [],
            notes: []
        )
        squad.athletes.append(newAthlete)
        dismiss()
    }
}
