import SwiftUI
import FirebaseCore


@main
struct Sportsapp: App {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("loggedInRole") private var loggedInRole = ""
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                Group {
                    if loggedInRole == "Athlete" {
                        AthleteDashboardView()
                    } else {
                        StaffDashboardView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Log Out") {
                            withAnimation {
                                isAuthenticated = false
                                loggedInRole = ""
                            }
                        }
                    }
                }
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
