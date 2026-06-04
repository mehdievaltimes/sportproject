import Foundation
import FirebaseFirestore
import Observation

@Observable
class AthleteManager {
    static let shared = AthleteManager()
    private let db = Firestore.firestore()
    
    // For Staff Dashboard
    var roster: [Athlete] = []
    var lastErrorMessage: String = ""
    
    // For Athlete Dashboard
    var currentAthlete: Athlete?
    
    private init() {}
    
    private var hasPerformedInitialFetch = false
    
    // For Staff: Fetch all athletes belonging to the team and listen to realtime updates
    func fetchTeamRoster(teamDomain: String) {
        let cleanDomain = teamDomain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        db.collection("athletes")
            .whereField("teamDomain", isEqualTo: cleanDomain)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.lastErrorMessage = "Firestore Error: \(error.localizedDescription)"
                    return
                }
                guard let snapshot = snapshot else {
                    self.lastErrorMessage = "Snapshot was unexpectedly nil"
                    return
                }
                
                for change in snapshot.documentChanges {
                    do {
                        let athlete = try change.document.data(as: Athlete.self)
                        
                        switch change.type {
                        case .added:
                            if let index = self.roster.firstIndex(where: { $0.id == athlete.id }) {
                                self.roster[index] = athlete
                            } else {
                                self.roster.append(athlete)
                            }
                        case .modified:
                            if let index = self.roster.firstIndex(where: { $0.id == athlete.id }) {
                                let oldAthlete = self.roster[index]
                                self.roster[index] = athlete
                                
                                if self.hasPerformedInitialFetch {
                                    self.checkForCriticalAlerts(old: oldAthlete, new: athlete)
                                }
                            } else {
                                self.roster.append(athlete)
                            }
                        case .removed:
                            self.roster.removeAll { $0.id == athlete.id }
                        }
                    } catch {
                        self.lastErrorMessage = "Decoding Error: \(error.localizedDescription)"
                        print("Error decoding athlete \(change.document.documentID): \(error)")
                    }
                }
                
                self.hasPerformedInitialFetch = true
            }
    }
    
    private func checkForCriticalAlerts(old: Athlete, new: Athlete) {
        if new.cycleLogs.count > old.cycleLogs.count {
            if let latestLog = new.cycleLogs.last, latestLog.readinessScore <= 3 {
                NotificationManager.shared.sendReadinessAlert(athleteName: new.name, score: latestLog.readinessScore)
            }
        }
    }
    
    // For Athletes: Fetch personal record and listen to realtime updates
    func fetchCurrentAthlete(uid: String) {
        db.collection("athletes").document(uid)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else {
                    print("Error fetching current athlete: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    self.currentAthlete = try document.data(as: Athlete.self)
                } catch {
                    print("Error decoding current athlete: \(error)")
                }
            }
    }
    
    // Save/Update an athlete's full data back to Firestore
    func saveAthlete(_ athlete: Athlete) {
        do {
            try db.collection("athletes").document(athlete.id).setData(from: athlete)
        } catch {
            print("Error saving athlete: \(error)")
        }
    }
}
