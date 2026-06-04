import Foundation

/// Core engine for processing and aggregating timeseries sports data
class AnalyticsEngine {
    static let shared = AnalyticsEngine()
    
    private init() {}
    
    /// Struct representing a unified snapshot of a single day
    struct DailySnapshot: Identifiable {
        let id = UUID()
        let date: Date
        
        let gpsSession: GPSSession?
        let healthMetric: HealthMetric?
        let cycleLog: CycleLog?
    }
    
    /// Merges an athlete's disparate data streams into a chronological array of unified daily snapshots
    func buildUnifiedTimeline(for athlete: Athlete, days: Int = 30) -> [DailySnapshot] {
        var timeline: [DailySnapshot] = []
        
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<days {
            guard let targetDate = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Find matches for this date
            let session = athlete.gpsSessions.first { calendar.isDate($0.date, inSameDayAs: targetDate) }
            let health = athlete.healthMetrics.first { calendar.isDate($0.date, inSameDayAs: targetDate) }
            let cycle = athlete.cycleLogs.first { calendar.isDate($0.date, inSameDayAs: targetDate) }
            
            if session != nil || health != nil || cycle != nil {
                timeline.append(DailySnapshot(
                    date: targetDate,
                    gpsSession: session,
                    healthMetric: health,
                    cycleLog: cycle
                ))
            }
        }
        
        return timeline.sorted { $0.date < $1.date }
    }
    
    // MARK: - ACWR and Predictive Load Models
    
    /// Calculates the Chronic Load (average daily load over the last 28 days)
    func chronicLoad(for athlete: Athlete) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let twentyEightDaysAgo = calendar.date(byAdding: .day, value: -28, to: today) ?? today
        
        let sessions = athlete.gpsSessions.filter { $0.date >= twentyEightDaysAgo && $0.date <= today }
        let totalLoad = sessions.reduce(0) { $0 + $1.playerLoad }
        
        // Chronic load is usually expressed as the daily average over 28 days
        return totalLoad / 28.0
    }
    
    /// Calculates the Acute Load (average daily load over the last 7 days)
    func acuteLoadDaily(for athlete: Athlete) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let sessions = athlete.gpsSessions.filter { $0.date >= sevenDaysAgo && $0.date <= today }
        let totalLoad = sessions.reduce(0) { $0 + $1.playerLoad }
        
        // Acute load is the daily average over 7 days
        return totalLoad / 7.0
    }
    
    /// Calculates the Acute:Chronic Workload Ratio (ACWR)
    func calculateACWR(for athlete: Athlete) -> Double {
        let acute = acuteLoadDaily(for: athlete)
        let chronic = chronicLoad(for: athlete)
        
        guard chronic > 0 else { return 0 }
        return acute / chronic
    }
    
    /// Predicts the Maximum Safe Training Load (Player Load AU) the athlete can tolerate TODAY without exceeding the 1.4 ACWR danger threshold.
    func predictedMaxSafeLoad(for athlete: Athlete) -> Double {
        let chronic = chronicLoad(for: athlete)
        guard chronic > 0 else { return 800 } // Baseline fallback if no chronic history
        
        // Target ACWR max is 1.4
        let maxSafeAcuteDaily = 1.4 * chronic
        let maxSafeAcuteWeeklySum = maxSafeAcuteDaily * 7.0
        
        // Sum the load from the previous 6 days (excluding today)
        let calendar = Calendar.current
        let today = Date()
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        
        let recentSessions = athlete.gpsSessions.filter {
            $0.date >= sixDaysAgo && !calendar.isDate($0.date, inSameDayAs: today)
        }
        let sixDaySum = recentSessions.reduce(0) { $0 + $1.playerLoad }
        
        // The remaining budget for today
        let safeLoadToday = maxSafeAcuteWeeklySum - sixDaySum
        
        // If they are already over the 7-day budget, the safe load might be negative, clamp to 0.
        return max(0, safeLoadToday)
    }
    
    /// Calculates the load already accumulated TODAY
    func loadToday(for athlete: Athlete) -> Double {
        let today = Date()
        let calendar = Calendar.current
        return athlete.gpsSessions
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.playerLoad }
    }
}
