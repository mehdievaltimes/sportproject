import Foundation
import Observation
#if canImport(HealthKit)
import HealthKit
#endif

@Observable
class HealthDataService {
    static let shared = HealthDataService()
    
    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()
    #endif
    
    // Status to reflect to the UI
    enum SyncStatus {
        case notStarted
        case syncing
        case success
        case unavailable
    }
    
    var status: SyncStatus = .notStarted
    
    private init() {}
    
    func requestAuthorizationAndFetch(completion: @escaping (Bool, Error?) -> Void) {
        status = .syncing
        
        #if canImport(HealthKit)
        if HKHealthStore.isHealthDataAvailable() {
            // Setup types to read
            guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
                  let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
                  let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
                
                self.status = .unavailable
                completion(false, NSError(domain: "HealthDataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "HealthKit types not available"]))
                return
            }
            
            let typesToRead: Set<HKObjectType> = [stepCount, hrv, restingHeartRate]
            
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.status = .success
                    } else {
                        self.status = .unavailable
                    }
                    completion(success, error)
                }
            }
        } else {
            // HealthKit is not supported on this platform/device (e.g. native macOS)
            DispatchQueue.main.async {
                self.status = .unavailable
                completion(false, NSError(domain: "HealthDataService", code: 403, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."]))
            }
        }
        #else
        // HealthKit framework is entirely missing
        DispatchQueue.main.async {
            self.status = .unavailable
            completion(false, NSError(domain: "HealthDataService", code: 501, userInfo: [NSLocalizedDescriptionKey: "HealthKit not imported."]))
        }
        #endif
    }
}
