import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let statusCode, let body):
            return "HTTP \(statusCode): \(body)"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func health() async throws -> HealthResponse {
        try await get(path: "/healthz")
    }

    func chatReply(_ body: ChatReplyRequest) async throws -> ChatReplyResponse {
        try await post(path: "/chat/reply", body: body)
    }

    func generatePhoto(_ body: PhotoGenerateRequest) async throws -> PhotoGenerateResponse {
        try await post(path: "/photos/generate", body: body)
    }

    private func get<T: Decodable>(path: String) async throws -> T {
        let url = AppConfig.apiBaseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await perform(request)
    }

    private func post<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let url = AppConfig.apiBaseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        return try await perform(request)
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.httpError(statusCode: httpResponse.statusCode, body: body)
        }
        return try decoder.decode(T.self, from: data)
    }
}
