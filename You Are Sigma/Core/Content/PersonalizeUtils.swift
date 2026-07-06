import Foundation

func personalize(_ text: String, name: String?) -> String {
    let who = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let resolved = who.isEmpty ? "boss" : who
    return text.replacingOccurrences(of: "{name}", with: resolved)
}
