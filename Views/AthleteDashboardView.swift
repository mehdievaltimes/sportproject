import SwiftUI
import FirebaseAuth

struct AthleteDashboardView: View {
    @AppStorage("loggedInName") private var loggedInName = ""
    @State private var syncStatus = HealthDataService.SyncStatus.notStarted
    
    @State private var athleteManager = AthleteManager.shared
    
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
                        
                        if athleteManager.currentAthlete != nil {
                            AthleteDetailView(athlete: Binding(
                                get: { athleteManager.currentAthlete! },
                                set: { 
                                    athleteManager.currentAthlete = $0
                                    athleteManager.saveAthlete($0)
                                }
                            ))
                        } else {
                            VStack {
                                Spacer()
                                ProgressView("Loading your profile...")
                                Spacer()
                            }
                        }
                    }
                    .navigationTitle("My Dashboard")
                }
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    HealthDataService.shared.requestAuthorizationAndFetch { success, error in
                        self.syncStatus = HealthDataService.shared.status
                    }
                    if let uid = Auth.auth().currentUser?.uid {
                        athleteManager.fetchCurrentAthlete(uid: uid)
                    }
                }
            } else {
                DataConsentView()
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
    }
}

#Preview {
    AthleteDashboardView()
}
