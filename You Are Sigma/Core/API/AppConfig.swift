import Foundation

enum AppConfig {
    static var apiBaseURL: URL {
        if let str = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
           let url = URL(string: str) { return url }
        return URL(string: "http://localhost:3000")!
    }
}
