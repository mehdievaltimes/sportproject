import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var role: String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

@Observable
class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    
    var currentUserProfile: UserProfile?
    
    private init() {}
    
    func fetchCurrentUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                if let profile = try snapshot?.data(as: UserProfile.self) {
                    DispatchQueue.main.async {
                        self.currentUserProfile = profile
                    }
                    completion(.success(profile))
                } else {
                    let err = NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
                    completion(.failure(err))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func createUserProfile(uid: String, firstName: String, lastName: String, email: String, role: String, completion: @escaping (Error?) -> Void) {
        let profile = UserProfile(firstName: firstName, lastName: lastName, email: email, role: role)
        
        do {
            try db.collection("users").document(uid).setData(from: profile) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.currentUserProfile = profile
                    }
                }
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
}
