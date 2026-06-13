import SwiftUI
import FirebaseFirestore

struct AddAthleteView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("loggedInTeamDomain") private var loggedInTeamDomain = ""
    
    @State private var email: String = ""
    @State private var isInviting = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Invite Athlete"), footer: Text("The athlete must already have an account created in the iOS app.")) {
                    TextField("Athlete's Email Address", text: $email)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red).font(.caption)
                }
                if !successMessage.isEmpty {
                    Text(successMessage).foregroundColor(.green).font(.caption)
                }
            }
            .padding()
            .frame(width: 400, height: 200)
            .navigationTitle("Invite Athlete")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isInviting {
                        ProgressView().controlSize(.small)
                    } else {
                        Button("Send Invite") {
                            sendInvite()
                        }
                        .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
    
    private func sendInvite() {
        isInviting = true
        errorMessage = ""
        successMessage = ""
        
        let targetEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let db = Firestore.firestore()
        
        // Find the user by email
        db.collection("users").whereField("email", isEqualTo: targetEmail).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Error searching for user: \(error.localizedDescription)"
                self.isInviting = false
                return
            }
            
            guard let documents = snapshot?.documents, let userDoc = documents.first else {
                self.errorMessage = "No athlete found with that email address."
                self.isInviting = false
                return
            }
            
            let uid = userDoc.documentID
            
            let invite = TeamInvite(
                athleteId: uid,
                athleteEmail: targetEmail,
                teamDomain: loggedInTeamDomain,
                status: .pending,
                timestamp: Date()
            )
            
            do {
                try db.collection("team_invites").document(invite.id).setData(from: invite)
                self.successMessage = "Invite sent successfully!"
                self.email = ""
                
                // Dismiss after a short delay so they see the success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss()
                }
            } catch {
                self.errorMessage = "Error sending invite: \(error.localizedDescription)"
            }
            
            self.isInviting = false
        }
    }
}
