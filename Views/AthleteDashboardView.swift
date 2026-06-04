import SwiftUI

struct AthleteDashboardView: View {
    @AppStorage("loggedInName") private var loggedInName = ""
    @State private var syncStatus = HealthDataService.SyncStatus.notStarted
    
    // For now, we mock the logged-in athlete's data
    @State private var athlete = MockData.shared.squads[0].athletes[0]
    
    var body: some View {
        Group {
            if UserManager.shared.currentUserProfile?.hasConsentedToData == true {
                NavigationStack {
                    VStack(spacing: 0) {
                        if syncStatus == .unavailable {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("We can't fetch Apple HealthKit / Flow data on macOS yet.")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                        }
                        
                        AthleteDetailView(athlete: $athlete)
                    }
                    .navigationTitle("My Dashboard")
                }
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    HealthDataService.shared.requestAuthorizationAndFetch { success, error in
                        self.syncStatus = HealthDataService.shared.status
                    }
                }
            } else {
                DataConsentView()
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .onAppear {
            if !loggedInName.isEmpty {
                athlete.name = loggedInName
            }
        }
    }
}

#Preview {
    AthleteDashboardView()
}
