import Foundation

struct Squad: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var athletes: [Athlete]
}

struct AthleteNote: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    let date: Date
    let author: String
    var content: String
}

enum AthleteStatus: String, Codable, Hashable, CaseIterable {
    case available = "Available"
    case modifiedTraining = "Modified Training"
    case rehab = "Rehab"
    case injured = "Injured"
}

struct InjuryEvent: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    let date: Date
    let bodyPart: String
    var expectedReturnDate: Date?
    var clearanceStatus: String?
}

struct Athlete: Identifiable, Hashable, Codable {
    var id: String // Mapped to Firebase Auth UID
    var teamDomain: String
    
    var name: String
    var positions: [String]
    var isTrackingCycle: Bool
    var currentCyclePhase: CyclePhase?
    
    // Vitals
    var height: Double? // cm
    var weight: Double? // kg
    
    // Decoupled Data Streams
    var gpsSessions: [GPSSession] = []
    var healthMetrics: [HealthMetric] = []
    var cycleLogs: [CycleLog] = []
    
    var notes: [AthleteNote] = []
    
    // Medical Tracking
    var status: AthleteStatus = .available
    var injuries: [InjuryEvent] = []
    
    // Helper to calculate acute load (7-day rolling sum of GPS Player Load)
    var acuteLoad: Double {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSessions = gpsSessions.filter { $0.date >= sevenDaysAgo }
        return recentSessions.reduce(0) { $0 + $1.playerLoad }
    }
}
