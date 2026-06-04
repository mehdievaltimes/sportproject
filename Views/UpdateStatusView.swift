import SwiftUI

struct UpdateStatusView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var athlete: Athlete
    
    @State private var selectedStatus: AthleteStatus
    @State private var positionsString: String
    @State private var name: String
    @State private var heightString: String
    @State private var weightString: String
    @State private var bodyPart: String = ""
    @State private var expectedReturnDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var clearanceStatus: String = "Evaluating"
    
    init(athlete: Binding<Athlete>) {
        self._athlete = athlete
        self._selectedStatus = State(initialValue: athlete.wrappedValue.status)
        self._positionsString = State(initialValue: athlete.wrappedValue.positions.joined(separator: ", "))
        self._name = State(initialValue: athlete.wrappedValue.name)
        
        if let h = athlete.wrappedValue.height {
            self._heightString = State(initialValue: String(format: "%.1f", h))
        } else {
            self._heightString = State(initialValue: "")
        }
        
        if let w = athlete.wrappedValue.weight {
            self._weightString = State(initialValue: String(format: "%.1f", w))
        } else {
            self._weightString = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Settings")) {
                    TextField("Full Name", text: $name)
                    TextField("Positions (comma-separated)", text: $positionsString)
                    HStack {
                        TextField("Height (cm)", text: $heightString)
                        TextField("Weight (kg)", text: $weightString)
                    }
                }
                
                Section(header: Text("Medical Status")) {
                    Picker("Current Status", selection: $selectedStatus) {
                        ForEach(AthleteStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if selectedStatus == .injured || selectedStatus == .rehab {
                    Section(header: Text("New Injury / Rehab Details")) {
                        TextField("Affected Body Part (e.g. Left Knee)", text: $bodyPart)
                        TextField("Clearance / Notes", text: $clearanceStatus)
                        DatePicker("Expected Return", selection: $expectedReturnDate, displayedComponents: .date)
                    }
                }
            }
            .padding()
            .frame(width: 450, height: selectedStatus == .injured || selectedStatus == .rehab ? 450 : 320)
            .navigationTitle("Edit Athlete Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStatus()
                    }
                }
            }
        }
    }
    
    private func saveStatus() {
        athlete.status = selectedStatus
        athlete.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        athlete.positions = positionsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        athlete.height = Double(heightString)
        athlete.weight = Double(weightString)
        
        if (selectedStatus == .injured || selectedStatus == .rehab) && !bodyPart.isEmpty {
            let newInjury = InjuryEvent(
                id: UUID().uuidString,
                date: Date(),
                bodyPart: bodyPart,
                expectedReturnDate: expectedReturnDate,
                clearanceStatus: clearanceStatus
            )
            // Prepend so it appears at the top
            athlete.injuries.insert(newInjury, at: 0)
        }
        
        AthleteManager.shared.saveAthlete(athlete)
        dismiss()
    }
}
