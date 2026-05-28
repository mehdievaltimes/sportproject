import Foundation

struct MockData {
    static let shared = MockData()
    
    let squads: [Squad]
    
    init() {
        let today = Date()
        
        let generateLoads = { () -> [DailyLoad] in
            var loads: [DailyLoad] = []
            for i in 0..<14 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                loads.append(DailyLoad(
                    id: UUID(),
                    date: date,
                    totalDistance: Double.random(in: 4000...8000),
                    highSpeedDistance: Double.random(in: 200...800),
                    maxSpeed: Double.random(in: 6.0...8.5),
                    restingHR: Double.random(in: 45...65),
                    hrv: Double.random(in: 40...100),
                    sleepDuration: Double.random(in: 6...9),
                    rpe: Int.random(in: 3...8),
                    wellnessScore: Int.random(in: 5...10)
                ))
            }
            return loads.sorted(by: { $0.date < $1.date })
        }
        
        let athletes = [
            Athlete(id: UUID(), name: "Sarah Jenkins", position: "Midfielder", isTrackingCycle: true, currentCyclePhase: .luteal, dailyLoads: generateLoads()),
            Athlete(id: UUID(), name: "Megan Rapinoe", position: "Forward", isTrackingCycle: true, currentCyclePhase: .follicular, dailyLoads: generateLoads()),
            Athlete(id: UUID(), name: "Alex Morgan", position: "Striker", isTrackingCycle: true, currentCyclePhase: .ovulatory, dailyLoads: generateLoads())
        ]
        
        self.squads = [
            Squad(id: UUID(), name: "First Team - Women", athletes: athletes)
        ]
    }
}
