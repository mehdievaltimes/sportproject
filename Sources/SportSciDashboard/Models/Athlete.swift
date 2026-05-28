import Foundation

struct Squad: Identifiable, Hashable {
    let id: UUID
    var name: String
    var athletes: [Athlete]
}

struct Athlete: Identifiable, Hashable {
    let id: UUID
    var name: String
    var position: String
    var isTrackingCycle: Bool
    var currentCyclePhase: CyclePhase?
    var dailyLoads: [DailyLoad]
    
    // Helper to calculate acute load (e.g. 7-day rolling sum/average)
    var acuteLoad: Double {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentLoads = dailyLoads.filter { $0.date >= sevenDaysAgo }
        return recentLoads.reduce(0) { $0 + $1.totalLoad }
    }
}
