import Foundation
import FirebaseFirestore
import Observation

@Observable
class AthleteManager {
    static let shared = AthleteManager()
    private let db = Firestore.firestore()
    
    // For Staff Dashboard
    var roster: [Athlete] = []
    
    // For Athlete Dashboard
    var currentAthlete: Athlete?
    
    private init() {}
    
    // For Staff: Fetch all athletes belonging to the team and listen to realtime updates
    func fetchTeamRoster(teamDomain: String) {
        db.collection("athletes")
            .whereField("teamDomain", isEqualTo: teamDomain)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching roster: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.roster = documents.compactMap { doc -> Athlete? in
                    do {
                        return try doc.data(as: Athlete.self)
                    } catch {
                        print("Error decoding athlete \(doc.documentID): \(error)")
                        return nil
                    }
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
