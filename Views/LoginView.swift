import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @AppStorage("loggedInEmail") private var loggedInEmail = ""
    @AppStorage("loggedInName") private var loggedInName = ""
    @AppStorage("loggedInRole") private var loggedInRole = ""
    @AppStorage("loggedInTeamDomain") private var loggedInTeamDomain = ""
    
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isAuthenticating = false
    @State private var isSignUp = false
    @State private var errorMessage = ""
    
    var isSignUpValid: Bool {
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo / Header
            VStack(spacing: 12) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                    .background(Circle().fill(Color.blue.opacity(0.1)))
                
                Text("SomeoneGiveThisaName")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Elite Roster Management & Recovery")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // Login Form
            VStack(spacing: 16) {
                if isSignUp {
                    HStack {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }
                    
                    Text("Your team will be assigned automatically based on your email domain.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: handleAuth) {
                    if isAuthenticating {
                        ProgressView()
                            .controlSize(.small)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isSignUp ? !isSignUpValid : (email.isEmpty || password.isEmpty || isAuthenticating))
                .padding(.top, 10)
                
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                        errorMessage = ""
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 360)
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
    
    private func handleAuth() {
        isAuthenticating = true
        errorMessage = ""
        
        if isSignUp {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isAuthenticating = false
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let calculatedTeamDomain = self.email.components(separatedBy: "@").last?.lowercased() ?? ""
                
                UserManager.shared.createUserProfile(uid: uid, firstName: self.firstName, lastName: self.lastName, email: self.email, role: "Staff", teamDomain: calculatedTeamDomain) { error in
                    DispatchQueue.main.async {
                        self.isAuthenticating = false
                        if let error = error {
                            self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                        } else {
                            self.loggedInEmail = self.email
                            self.loggedInName = "\(self.firstName) \(self.lastName)"
//                            self.loggedInRole = self.selectedRole
                            self.loggedInTeamDomain = calculatedTeamDomain
                            withAnimation(.spring()) {
                                self.isAuthenticated = true
                            }
                        }
                    }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isAuthenticating = false
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                UserManager.shared.fetchCurrentUserProfile(uid: uid) { fetchResult in
                    DispatchQueue.main.async {
                        self.isAuthenticating = false
                        switch fetchResult {
                        case .success(let profile):
                            if profile.role == "Athlete" {
                                try? Auth.auth().signOut()
                                self.errorMessage = "Access Denied: This macOS app is restricted to coaching staff only."
                            } else {
                                self.loggedInEmail = profile.email
                                self.loggedInName = profile.fullName
                                self.loggedInRole = profile.role
                                self.loggedInTeamDomain = profile.teamDomain
                                withAnimation(.spring()) {
                                    self.isAuthenticated = true
                                }
                            }
                        case .failure(let error):
                            self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}
