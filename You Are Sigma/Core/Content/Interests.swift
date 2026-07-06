import Foundation

func matchCategories(_ bio: String) -> [Category] {
    Category.allCases.filter { category in
        categoryKeywords[category]?.contains { keywordMatches($0, in: bio) } ?? false
    }
}

private func keywordMatches(_ keyword: String, in bio: String) -> Bool {
    let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return false }
    let range = NSRange(bio.startIndex..<bio.endIndex, in: bio)
    return regex.firstMatch(in: bio, options: [], range: range) != nil
}

private let categoryKeywords: [Category: [String]] = [
    .basketball: ["nba", "basketball", "hooper", "hoops", "baller", "wnba"],
    .soccer: ["soccer", "footballer", "premier league", "fifa", "striker", "uefa"],
    .tennis: ["tennis", "atp", "wta", "grand slam", "wimbledon"],
    .football: ["nfl", "american football", "quarterback", "touchdown", "super bowl"],
    .music: ["musician", "rapper", "singer", "songwriter", "dj", "music", "artist", "grammy"],
    .tech: ["software", "engineer", "developer", "startup", "founder", "ceo", "tech", "ai", "coder"],
    .film: ["actor", "actress", "director", "filmmaker", "hollywood", "movie", "oscar"],
    .business: ["investor", "billionaire", "entrepreneur", "finance", "hedge fund", "vc", "mogul"],
    .boxing: ["boxer", "boxing", "heavyweight", "knockout"],
    .mma: ["mma", "ufc", "fighter", "octagon"],
    .golf: ["golf", "golfer", "pga"],
    .f1: ["formula 1", "formula one", "f1", "grand prix", "motorsport"],
    .fashion: ["model", "supermodel", "fashion", "designer", "runway"],
    .politics: ["president", "senator", "politician", "governor"],
]
