import Foundation

class STATSportsParser {
    static let shared = STATSportsParser()
    
    // Expected CSV format: Date,Player Name,Total Distance,High Speed Distance,Max Speed
    func parse(csvString: String, squad: inout Squad) {
        let lines = csvString.components(separatedBy: .newlines)
        guard lines.count > 1 else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for line in lines.dropFirst() {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 5 {
                let dateStr = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let name = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let distance = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                let highSpeed = Double(columns[3].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                let maxSpeed = Double(columns[4].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                
                if let date = dateFormatter.date(from: dateStr),
                   let athleteIndex = squad.athletes.firstIndex(where: { $0.name == name }) {
                    
                    let newSession = GPSSession(
                        id: UUID(),
                        date: date,
                        duration: 90.0, // Defaulted for this simple CSV
                        totalDistance: distance,
                        workRate: distance / 90.0,
                        maxSpeed: maxSpeed,
                        highSpeedRunningDistance: highSpeed,
                        sprintDistance: highSpeed * 0.3, // Estimated
                        playerLoad: distance * 0.1, // Estimated
                        metabolicPower: 10.0, // Default mock
                        highMetabolicLoadDistance: highSpeed * 1.5,
                        accelerationsTotal: 30,
                        accelerationsHighIntensity: 10,
                        decelerationsTotal: 30,
                        decelerationsHighIntensity: 10,
                        stepBalanceAsymmetry: 0.0,
                        impactsHighGForce: 15
                    )
                    
                    squad.athletes[athleteIndex].gpsSessions.append(newSession)
                    squad.athletes[athleteIndex].gpsSessions.sort { $0.date < $1.date }
                }
            }
        }
    }
}
