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
    
    // Wearables / HealthKit - Cardiovascular & Vitals
    var restingHR: Double? // bpm
    var hrv: Double? // ms
    var vo2Max: Double? // mL/kg/min
    var spO2: Double? // percentage (0.0-1.0)
    var respiratoryRate: Double? // breaths per min
    var basalBodyTemp: Double? // Celsius
    
    // Wearables / HealthKit - Sleep
    var sleepDuration: Double? // hours
    var sleepDeep: Double? // hours
    var sleepRem: Double? // hours
    var sleepCore: Double? // hours
    var sleepAwake: Double? // hours
    
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
    
    init(id: UUID = UUID(), date: Date, totalDistance: Double, highSpeedDistance: Double, maxSpeed: Double, restingHR: Double? = nil, hrv: Double? = nil, vo2Max: Double? = nil, spO2: Double? = nil, respiratoryRate: Double? = nil, basalBodyTemp: Double? = nil, sleepDuration: Double? = nil, sleepDeep: Double? = nil, sleepRem: Double? = nil, sleepCore: Double? = nil, sleepAwake: Double? = nil, rpe: Int? = nil, wellnessScore: Int? = nil) {
        self.id = id
        self.date = date
        self.totalDistance = totalDistance
        self.highSpeedDistance = highSpeedDistance
        self.maxSpeed = maxSpeed
        self.restingHR = restingHR
        self.hrv = hrv
        self.vo2Max = vo2Max
        self.spO2 = spO2
        self.respiratoryRate = respiratoryRate
        self.basalBodyTemp = basalBodyTemp
        self.sleepDuration = sleepDuration
        self.sleepDeep = sleepDeep
        self.sleepRem = sleepRem
        self.sleepCore = sleepCore
        self.sleepAwake = sleepAwake
        self.rpe = rpe
        self.wellnessScore = wellnessScore
    }
}
