import Foundation

enum CyclePhase: String, Codable, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"
}

struct DailyLoad: Identifiable, Hashable {
    let id: UUID
    let date: Date
    
    // GPS Data (STATSports)
    var totalDistance: Double // meters
    var highSpeedDistance: Double // meters
    var maxSpeed: Double // m/s
    
    // Wearables / HealthKit
    var restingHR: Double? // bpm
    var hrv: Double? // ms
    var sleepDuration: Double? // hours
    
    // Manual Input
    var rpe: Int? // 1-10
    var wellnessScore: Int? // 1-10
    
    // Calculated total load (simplistic)
    var totalLoad: Double {
        // e.g., session RPE = RPE * duration (if we had duration), or simply use distance + highSpeed as a proxy
        let gpsLoad = (totalDistance * 0.1) + (highSpeedDistance * 0.5)
        let subjectiveLoad = Double(rpe ?? 5) * 10.0
        return gpsLoad + subjectiveLoad
    }
}
