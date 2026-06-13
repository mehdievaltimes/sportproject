import Foundation

enum InviteStatus: String, Codable, Hashable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

struct TeamInvite: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var athleteId: String
    var athleteEmail: String
    var teamDomain: String
    var status: InviteStatus
    var timestamp: Date
}
