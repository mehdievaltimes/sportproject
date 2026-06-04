import Foundation

import Foundation

enum CyclePhase: String, Codable, CaseIterable {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"
}

struct GPSSession: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let duration: Double // minutes
    
    // Volume & Speed
    var totalDistance: Double // meters
    var workRate: Double // meters/min
    var maxSpeed: Double // m/s
    var highSpeedRunningDistance: Double // m (> 5.5 m/s)
    var sprintDistance: Double // m (> 7.0 m/s)
    
    // Mechanical & Metabolic Load
    var playerLoad: Double
    var metabolicPower: Double // W/kg
    var highMetabolicLoadDistance: Double // HMLD
    var accelerationsTotal: Int
    var accelerationsHighIntensity: Int
    var decelerationsTotal: Int
    var decelerationsHighIntensity: Int
    var stepBalanceAsymmetry: Double // L/R asymmetry percentage
    var impactsHighGForce: Int // impacts > 8G
}

struct HealthMetric: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    
    // Cardiovascular
    var restingHR: Double? // bpm
    var hrv: Double? // ms
    var vo2Max: Double?
    var spO2: Double? // percentage
    var respiratoryRate: Double?
    
    // Sleep & Recovery
    var basalBodyTemp: Double? // Celsius
    var sleepTotalDuration: Double? // hours
    var sleepDeep: Double? // hours
    var sleepRem: Double? // hours
}

struct CycleLog: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    
    var phase: CyclePhase
    var symptoms: Int // e.g., 1-5 severity scale
    var flowIntensity: Int // 1-5 scale
    var readinessScore: Int // 1-10 subjective
}
