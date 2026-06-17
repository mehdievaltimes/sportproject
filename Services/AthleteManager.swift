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
    
    private var subcollectionListeners: [String: [ListenerRegistration]] = [:]
    
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
                                let oldAthlete = self.roster[index]
                                var newAthlete = athlete
                                newAthlete.gpsSessions = oldAthlete.gpsSessions
                                newAthlete.healthMetrics = oldAthlete.healthMetrics
                                newAthlete.cycleLogs = oldAthlete.cycleLogs
                                self.roster[index] = newAthlete
                            } else {
                                self.roster.append(athlete)
                                self.fetchSubcollections(for: athlete.id)
                            }
                        case .modified:
                            if let index = self.roster.firstIndex(where: { $0.id == athlete.id }) {
                                let oldAthlete = self.roster[index]
                                var newAthlete = athlete
                                newAthlete.gpsSessions = oldAthlete.gpsSessions
                                newAthlete.healthMetrics = oldAthlete.healthMetrics
                                newAthlete.cycleLogs = oldAthlete.cycleLogs
                                self.roster[index] = newAthlete
                            } else {
                                self.roster.append(athlete)
                                self.fetchSubcollections(for: athlete.id)
                            }
                        case .removed:
                            self.roster.removeAll { $0.id == athlete.id }
                            self.stopListeningToSubcollections(for: athlete.id)
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
        // Checking for critical alerts can be done at subcollection level if needed.
    }
    
    private func fetchSubcollections(for uid: String) {
        if subcollectionListeners[uid] != nil { return } // already listening
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let gps = db.collection("athletes").document(uid).collection("gps_sessions")
            .whereField("date", isGreaterThanOrEqualTo: thirtyDaysAgo)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let sessions = docs.compactMap { try? $0.data(as: GPSSession.self) }.sorted { $0.date < $1.date }
                if let index = self.roster.firstIndex(where: { $0.id == uid }) {
                    self.roster[index].gpsSessions = sessions
                }
            }
            
        let health = db.collection("athletes").document(uid).collection("health_metrics")
            .whereField("date", isGreaterThanOrEqualTo: thirtyDaysAgo)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let metrics = docs.compactMap { try? $0.data(as: HealthMetric.self) }.sorted { $0.date < $1.date }
                if let index = self.roster.firstIndex(where: { $0.id == uid }) {
                    self.roster[index].healthMetrics = metrics
                }
            }
            
        let cycle = db.collection("athletes").document(uid).collection("cycle_logs")
            .whereField("date", isGreaterThanOrEqualTo: thirtyDaysAgo)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let logs = docs.compactMap { try? $0.data(as: CycleLog.self) }.sorted { $0.date < $1.date }
                if let index = self.roster.firstIndex(where: { $0.id == uid }) {
                    self.roster[index].cycleLogs = logs
                    
                    if let latestLog = logs.last, latestLog.readinessScore <= 3 {
                        NotificationManager.shared.sendReadinessAlert(athleteName: self.roster[index].name, score: latestLog.readinessScore)
                    }
                }
            }
            
        subcollectionListeners[uid] = [gps, health, cycle]
    }
    
    private func stopListeningToSubcollections(for uid: String) {
        subcollectionListeners[uid]?.forEach { $0.remove() }
        subcollectionListeners.removeValue(forKey: uid)
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
    
    // Save/Update an athlete's root document back to Firestore
    func saveAthleteRoot(_ athlete: Athlete) {
        do {
            try db.collection("athletes").document(athlete.id).setData(from: athlete)
        } catch {
            print("Error saving athlete root: \(error)")
        }
    }
    
    // Legacy support
    func saveAthlete(_ athlete: Athlete) {
        saveAthleteRoot(athlete)
    }
    
    func saveHealthMetric(_ metric: HealthMetric, uid: String) {
        do {
            try db.collection("athletes").document(uid).collection("health_metrics").document(metric.id.uuidString).setData(from: metric)
        } catch { print("Error saving health metric: \(error)") }
    }
    
    func saveCycleLog(_ log: CycleLog, uid: String) {
        do {
            try db.collection("athletes").document(uid).collection("cycle_logs").document(log.id.uuidString).setData(from: log)
        } catch { print("Error saving cycle log: \(error)") }
    }
    
    func saveGPSSession(_ session: GPSSession, uid: String) {
        do {
            try db.collection("athletes").document(uid).collection("gps_sessions").document(session.id.uuidString).setData(from: session)
        } catch { print("Error saving GPS session: \(error)") }
    }
}
