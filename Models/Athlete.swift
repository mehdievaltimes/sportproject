import Foundation

struct Squad: Identifiable, Hashable {
    let id: UUID
    var name: String
    var athletes: [Athlete]
}

struct AthleteNote: Identifiable, Hashable {
    let id: UUID
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

struct InjuryEvent: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let bodyPart: String
    var expectedReturnDate: Date?
    var clearanceStatus: String?
}

struct Athlete: Identifiable, Hashable {
    let id: UUID
    var name: String
    var position: String
    var isTrackingCycle: Bool
    var currentCyclePhase: CyclePhase?
    var dailyLoads: [DailyLoad]
    var notes: [AthleteNote]
    
    // Medical Tracking
    var status: AthleteStatus = .available
    var injuries: [InjuryEvent] = []
    
    // Helper to calculate acute load (e.g. 7-day rolling sum/average)
    var acuteLoad: Double {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentLoads = dailyLoads.filter { $0.date >= sevenDaysAgo }
        return recentLoads.reduce(0) { $0 + $1.totalLoad }
    }
}
