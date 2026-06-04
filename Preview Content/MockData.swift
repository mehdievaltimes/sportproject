import Foundation

struct MockData {
    static let shared = MockData()
    
    let squads: [Squad]
    
    init() {
        let today = Date()
        
        let generateGPSSessions = { () -> [GPSSession] in
            var sessions: [GPSSession] = []
            for i in 0..<60 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                sessions.append(GPSSession(
                    id: UUID(),
                    date: date,
                    duration: Double.random(in: 45...120),
                    totalDistance: Double.random(in: 4000...8000),
                    workRate: Double.random(in: 60...110),
                    maxSpeed: Double.random(in: 6.0...8.5),
                    highSpeedRunningDistance: Double.random(in: 200...800),
                    sprintDistance: Double.random(in: 50...250),
                    playerLoad: Double.random(in: 300...700),
                    metabolicPower: Double.random(in: 8...15),
                    highMetabolicLoadDistance: Double.random(in: 500...1500),
                    accelerationsTotal: Int.random(in: 20...50),
                    accelerationsHighIntensity: Int.random(in: 5...15),
                    decelerationsTotal: Int.random(in: 20...50),
                    decelerationsHighIntensity: Int.random(in: 5...15),
                    stepBalanceAsymmetry: Double.random(in: -3.0...3.0),
                    impactsHighGForce: Int.random(in: 10...30)
                ))
            }
            return sessions.sorted(by: { $0.date < $1.date })
        }
        
        let generateHealthMetrics = { () -> [HealthMetric] in
            var metrics: [HealthMetric] = []
            for i in 0..<60 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                let totalSleep = Double.random(in: 6...9)
                metrics.append(HealthMetric(
                    id: UUID(),
                    date: date,
                    restingHR: Double.random(in: 45...65),
                    hrv: Double.random(in: 40...100),
                    vo2Max: Double.random(in: 45...60),
                    spO2: Double.random(in: 0.95...1.0),
                    respiratoryRate: Double.random(in: 12...18),
                    basalBodyTemp: Double.random(in: 36.1...37.2),
                    sleepTotalDuration: totalSleep,
                    sleepDeep: totalSleep * 0.20,
                    sleepRem: totalSleep * 0.25
                ))
            }
            return metrics.sorted(by: { $0.date < $1.date })
        }
        
        let generateCycleLogs = { () -> [CycleLog] in
            var logs: [CycleLog] = []
            for i in 0..<60 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                logs.append(CycleLog(
                    id: UUID(),
                    date: date,
                    phase: .follicular,
                    symptoms: Int.random(in: 1...5),
                    flowIntensity: Int.random(in: 1...5),
                    readinessScore: Int.random(in: 1...10)
                ))
            }
            return logs.sorted(by: { $0.date < $1.date })
        }
        
        let sampleNotes = [
            AthleteNote(id: UUID().uuidString, date: today.addingTimeInterval(-86400 * 2), author: "Dr. Smith", content: "Athlete complained of slight hamstring tightness after the speed session."),
            AthleteNote(id: UUID().uuidString, date: today, author: "Coach Taylor", content: "Cleared for full training, but monitor RPE closely.")
        ]
        
        let athletes = [
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Sarah Jenkins", positions: ["Midfielder", "Center Mid", "Right Back"], isTrackingCycle: true, currentCyclePhase: .luteal, height: 168.0, weight: 62.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: sampleNotes, status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Megan Rapinoe", positions: ["Forward", "Winger"], isTrackingCycle: true, currentCyclePhase: .follicular, height: 170.0, weight: 60.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .injured, injuries: [
                InjuryEvent(id: UUID().uuidString, date: today.addingTimeInterval(-86400 * 5), bodyPart: "Right Knee (MCL Sprain)", expectedReturnDate: today.addingTimeInterval(86400 * 21), clearanceStatus: "Pending MRI")
            ]),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Alex Morgan", positions: ["Striker", "Forward"], isTrackingCycle: true, currentCyclePhase: .ovulatory, height: 173.0, weight: 62.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .modifiedTraining, injuries: [
                InjuryEvent(id: UUID().uuidString, date: today.addingTimeInterval(-86400 * 2), bodyPart: "Left Hamstring tightness", expectedReturnDate: today.addingTimeInterval(86400 * 3), clearanceStatus: "Daily check with physio")
            ]),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Sophia Smith", positions: ["Forward", "Winger"], isTrackingCycle: true, currentCyclePhase: .menstrual, height: 167.0, weight: 59.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Trinity Rodman", positions: ["Winger", "Forward"], isTrackingCycle: true, currentCyclePhase: .luteal, height: 175.0, weight: 65.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Rose Lavelle", positions: ["Attacking Midfielder", "Center Mid"], isTrackingCycle: true, currentCyclePhase: .follicular, height: 163.0, weight: 55.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Lindsey Horan", positions: ["Center Mid", "Defensive Midfielder"], isTrackingCycle: true, currentCyclePhase: .ovulatory, height: 175.0, weight: 68.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Crystal Dunn", positions: ["Left Back", "Midfielder"], isTrackingCycle: true, currentCyclePhase: .menstrual, height: 155.0, weight: 54.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Naomi Girma", positions: ["Center Back"], isTrackingCycle: true, currentCyclePhase: .luteal, height: 168.0, weight: 61.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Emily Fox", positions: ["Right Back", "Left Back"], isTrackingCycle: true, currentCyclePhase: .follicular, height: 165.0, weight: 58.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .modifiedTraining, injuries: [
                InjuryEvent(id: UUID().uuidString, date: today.addingTimeInterval(-86400 * 1), bodyPart: "Right Ankle Tweak", expectedReturnDate: today.addingTimeInterval(86400 * 2), clearanceStatus: "Day to day")
            ]),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Alyssa Naeher", positions: ["Goalkeeper"], isTrackingCycle: true, currentCyclePhase: .ovulatory, height: 175.0, weight: 69.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: []),
            Athlete(id: UUID().uuidString, teamDomain: "mockteam.com", name: "Mallory Swanson", positions: ["Forward", "Winger"], isTrackingCycle: true, currentCyclePhase: .luteal, height: 163.0, weight: 56.0, gpsSessions: generateGPSSessions(), healthMetrics: generateHealthMetrics(), cycleLogs: generateCycleLogs(), notes: [], status: .available, injuries: [])
        ]
        
        self.squads = [
            Squad(id: UUID().uuidString, name: "US Women's National Team", athletes: athletes)
        ]
    }
}
