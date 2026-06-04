import SwiftUI

struct UpdateStatusView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var athlete: Athlete
    
    @State private var selectedStatus: AthleteStatus
    @State private var bodyPart: String = ""
    @State private var expectedReturnDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var clearanceStatus: String = "Evaluating"
    
    init(athlete: Binding<Athlete>) {
        self._athlete = athlete
        self._selectedStatus = State(initialValue: athlete.wrappedValue.status)
    }
    
    var body: some View {
        NavigationStack {
            Form {
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
            .frame(width: 450, height: selectedStatus == .injured || selectedStatus == .rehab ? 350 : 200)
            .navigationTitle("Update Medical Status")
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
        
        // If they are marked available, optionally we could clear injuries, but for historical tracking we'll just leave them in the array, or maybe add a "Cleared" status to the active injury. For MVP, just changing status to available is enough.
        
        dismiss()
    }
}
