import SwiftUI

struct DataConsentView: View {
    @State private var isSaving = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .padding()
            
            Text("Connect Your Data")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("To provide you with accurate daily load tracking and recovery metrics, we need permission to securely sync your data from Apple HealthKit and Flow.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Daily Wellness & Readiness")
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Heart Rate Variability (HRV)")
                }
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Training Load & Recovery")
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(12)
            
            Button(action: {
                isSaving = true
                UserManager.shared.updateConsent(hasConsented: true)
            }) {
                if isSaving {
                    ProgressView().controlSize(.small)
                        .frame(width: 200)
                } else {
                    Text("Allow Access")
                        .fontWeight(.semibold)
                        .frame(width: 200)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 20)
            .disabled(isSaving)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    DataConsentView()
}
