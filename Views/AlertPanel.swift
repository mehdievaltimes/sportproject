import SwiftUI

struct AlertPanel: View {
    var alerts: [RecoveryAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Engine Insights ✦")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
            
            if alerts.isEmpty {
                Text("No active alerts.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(alerts) { alert in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon(for: alert.severity))
                            .foregroundColor(alert.severity.color)
                            .font(.title3)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(alert.title)
                                .font(.headline)
                            Text(alert.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(alert.severity.color.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(alert.severity.color.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    func icon(for severity: AlertSeverity) -> String {
        switch severity {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}
