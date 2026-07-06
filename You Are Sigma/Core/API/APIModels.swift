import Foundation

struct HealthResponse: Codable {
    let status: String
}

struct ChatHistoryItem: Codable {
    let from: String
    let text: String
}

struct ChatReplyRequest: Codable {
    let persona: String
    let handle: String?
    let history: [ChatHistoryItem]
    let message: String
    let userName: String?
    let userPersona: String?
}

struct ChatReplyResponse: Codable {
    let reply: String
}

struct PhotoGenerateRequest: Codable {
    let image: String
    let mimeType: String
    let prompt: String
}

struct PhotoGenerateResponse: Codable {
    let b64_json: String
    let mimeType: String
}

struct UserProfile: Codable {
    var name: String = ""
    var bio: String = ""
    var selfieData: Data? = nil
    var selfieMimeType: String = "image/jpeg"
}

struct GeneratedPhoto: Codable, Identifiable {
    var id: UUID = UUID()
    var imageData: Data
    var mimeType: String
    var prompt: String
    var lookLabel: String
    var createdAt: Date = Date()
}
