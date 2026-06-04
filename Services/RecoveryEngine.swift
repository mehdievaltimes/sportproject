import Foundation
import SwiftUI

enum AlertSeverity: String {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

struct RecoveryAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let severity: AlertSeverity
}

class RecoveryEngine {
    static let shared = RecoveryEngine()
    
    // Core logic: The Cycle-Phase-Aware Load Scoring Engine
    func evaluate(athlete: Athlete) -> [RecoveryAlert] {
        var alerts: [RecoveryAlert] = []
        
        let acuteLoad = athlete.acuteLoad
        // For MVP, simulating a chronic load (28-day average) by using acuteLoad as a baseline
        let chronicLoad = acuteLoad * 0.9 // just a dummy calculation
        
        let acRatio = chronicLoad > 0 ? acuteLoad / chronicLoad : 0.0
        
        // Rule 1: High AC Ratio
        if acRatio > 1.3 {
            alerts.append(RecoveryAlert(
                title: "High Acute:Chronic Workload",
                message: String(format: "A:C Ratio is %.2f. High risk of injury.", acRatio),
                severity: .critical
            ))
        }
        
        // Rule 2: Cycle Phase specific insights (The Moat ✦)
        if athlete.isTrackingCycle, let phase = athlete.currentCyclePhase {
            switch phase {
            case .luteal:
                // Luteal phase: Core body temp rises, recovery can be compromised, higher perceived exertion
                if let lastLog = athlete.cycleLogs.last, lastLog.readinessScore <= 4 {
                    alerts.append(RecoveryAlert(
                        title: "Luteal Phase Load Warning",
                        message: "Athlete is in the Luteal phase and reported low readiness (\(lastLog.readinessScore)/10). Consider reducing high-speed distance today to aid recovery.",
                        severity: .warning
                    ))
                }
            case .menstrual:
                // Menstrual phase: Some athletes experience fatigue or cramping
                alerts.append(RecoveryAlert(
                    title: "Menstrual Phase Note",
                    message: "Monitor for symptoms of fatigue. Ensure adequate iron intake and hydration.",
                    severity: .info
                ))
            case .follicular, .ovulatory:
                // Generally higher energy levels and better recovery
                break
            }
        }
        
        // Rule 3: Sleep Drop
        if let lastSleep = athlete.healthMetrics.last?.sleepTotalDuration, lastSleep < 6.0 {
            alerts.append(RecoveryAlert(
                title: "Poor Sleep Recovery",
                message: String(format: "Only %.1f hours of sleep last night. Recovery capability reduced.", lastSleep),
                severity: .warning
            ))
        }
        
        return alerts
    }
}
