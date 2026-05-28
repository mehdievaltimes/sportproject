import SwiftUI
@main
struct SportSciDashboard: App {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
                    // Provide a way to log out from the main menu if desired, or just through a button.
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Log Out") {
                                withAnimation {
                                    isAuthenticated = false
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
