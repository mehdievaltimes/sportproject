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
                    
                    let newLoad = DailyLoad(
                        id: UUID(),
                        date: date,
                        totalDistance: distance,
                        highSpeedDistance: highSpeed,
                        maxSpeed: maxSpeed,
                        restingHR: nil, hrv: nil, sleepDuration: nil, rpe: nil, wellnessScore: nil
                    )
                    
                    squad.athletes[athleteIndex].dailyLoads.append(newLoad)
                    squad.athletes[athleteIndex].dailyLoads.sort { $0.date < $1.date }
                }
            }
        }
    }
}
