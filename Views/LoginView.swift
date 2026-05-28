import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo / Header
            VStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Circle().fill(Color.blue.opacity(0.1)))
                
                Text("SportSci OS")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Elite Roster Management & Recovery")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // Login Form
            VStack(spacing: 16) {
                TextField("Work Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                
                Button(action: login) {
                    if isAuthenticating {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || isAuthenticating)
                .padding(.top, 10)
            }
            .frame(width: 320)
            .padding(40)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Color.blue.opacity(0.05)
                // Add a subtle background pattern or gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            .ignoresSafeArea()
        )
    }
    
    private func login() {
        isAuthenticating = true
        // Simulate network delay for a real feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring()) {
                isAuthenticated = true
            }
        }
    }
}
