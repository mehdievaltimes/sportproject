import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendReadinessAlert(athleteName: String, score: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Critical Readiness Alert"
        content.body = "\(athleteName) logged a readiness score of \(score)/10. Review their training load immediately."
        content.sound = .default
        
        // Use a UUID so multiple alerts stack uniquely rather than overwriting each other
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error dispatching notification: \(error.localizedDescription)")
            }
        }
    }
}
