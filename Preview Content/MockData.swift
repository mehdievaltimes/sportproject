import Foundation

struct MockData {
    static let shared = MockData()
    
    let squads: [Squad]
    
    init() {
        let today = Date()
        
        let generateLoads = { () -> [DailyLoad] in
            var loads: [DailyLoad] = []
            for i in 0..<60 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                let totalSleep = Double.random(in: 6...9)
                let deep = totalSleep * 0.20
                let rem = totalSleep * 0.25
                let core = totalSleep * 0.50
                let awake = totalSleep * 0.05
                
                loads.append(DailyLoad(
                    id: UUID(),
                    date: date,
                    totalDistance: Double.random(in: 4000...8000),
                    highSpeedDistance: Double.random(in: 200...800),
                    maxSpeed: Double.random(in: 6.0...8.5),
                    restingHR: Double.random(in: 45...65),
                    hrv: Double.random(in: 40...100),
                    vo2Max: Double.random(in: 45...60),
                    spO2: Double.random(in: 0.95...1.0),
                    respiratoryRate: Double.random(in: 12...18),
                    basalBodyTemp: Double.random(in: 36.1...37.2),
                    sleepDuration: totalSleep,
                    sleepDeep: deep,
                    sleepRem: rem,
                    sleepCore: core,
                    sleepAwake: awake,
                    rpe: Int.random(in: 3...8),
                    wellnessScore: Int.random(in: 5...10)
                ))
            }
            return loads.sorted(by: { $0.date < $1.date })
        }
        
        let sampleNotes = [
            AthleteNote(id: UUID(), date: today.addingTimeInterval(-86400 * 2), author: "Dr. Smith", content: "Athlete complained of slight hamstring tightness after the speed session."),
            AthleteNote(id: UUID(), date: today, author: "Coach Taylor", content: "Cleared for full training, but monitor RPE closely.")
        ]
        
        let athletes = [
            Athlete(id: UUID(), name: "Sarah Jenkins", position: "Midfielder", isTrackingCycle: true, currentCyclePhase: .luteal, dailyLoads: generateLoads(), notes: sampleNotes, status: .available, injuries: []),
            Athlete(id: UUID(), name: "Megan Rapinoe", position: "Forward", isTrackingCycle: true, currentCyclePhase: .follicular, dailyLoads: generateLoads(), notes: [], status: .injured, injuries: [
                InjuryEvent(id: UUID(), date: today.addingTimeInterval(-86400 * 5), bodyPart: "Right Knee (MCL Sprain)", expectedReturnDate: today.addingTimeInterval(86400 * 21), clearanceStatus: "Pending MRI")
            ]),
            Athlete(id: UUID(), name: "Alex Morgan", position: "Striker", isTrackingCycle: true, currentCyclePhase: .ovulatory, dailyLoads: generateLoads(), notes: [], status: .modifiedTraining, injuries: [
                InjuryEvent(id: UUID(), date: today.addingTimeInterval(-86400 * 2), bodyPart: "Left Hamstring tightness", expectedReturnDate: today.addingTimeInterval(86400 * 3), clearanceStatus: "Daily check with physio")
            ])
        ]
        
        self.squads = [
            Squad(id: UUID(), name: "First Team - Women", athletes: athletes)
        ]
    }
}
