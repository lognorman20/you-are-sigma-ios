import Foundation

enum Category: String, CaseIterable {
    case basketball, soccer, tennis, football, boxing, mma, golf, f1, music, film, tech, business, fashion, politics
}

struct Person: Identifiable {
    let id: String
    let name: String
    let handle: String
    let verified: Bool
    let tags: [Category]
    let initials: String
}

let categoryOrder: [Category] = [.basketball, .soccer, .tennis, .football, .boxing, .mma, .golf, .f1, .music, .film, .tech, .business, .fashion, .politics]

func slugify(_ name: String) -> String {
    name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        .lowercased().replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
}

private func initialsOf(_ name: String) -> String {
    let parts = name.replacingOccurrences(of: "[()]", with: "", options: .regularExpression).split(separator: " ").map(String.init)
    guard let first = parts.first else { return "?" }
    if parts.count == 1 { return String(first.prefix(2)).uppercased() }
    return "\(first.prefix(1))\(parts.last!.prefix(1))".uppercased()
}

private struct PersonSeed { let name: String; let handle: String; let tags: [Category] }

private let seeds: [PersonSeed] = [
    PersonSeed(name: "LeBron James", handle: "LA Lakers", tags: [.basketball, .business]),
    PersonSeed(name: "Stephen Curry", handle: "Golden State Warriors", tags: [.basketball]),
    PersonSeed(name: "Cristiano Ronaldo", handle: "Al Nassr / CR7", tags: [.soccer]),
    PersonSeed(name: "Lionel Messi", handle: "Inter Miami", tags: [.soccer]),
    PersonSeed(name: "Roger Federer", handle: "Tennis Legend", tags: [.tennis]),
    PersonSeed(name: "Tom Brady", handle: "GOAT", tags: [.football]),
    PersonSeed(name: "Drake", handle: "OVO Sound", tags: [.music]),
    PersonSeed(name: "Rihanna", handle: "Fenty / Savage", tags: [.music, .business, .fashion]),
    PersonSeed(name: "Taylor Swift", handle: "Recording Artist", tags: [.music]),
    PersonSeed(name: "Beyoncé", handle: "Parkwood Ent.", tags: [.music]),
    PersonSeed(name: "Jay-Z", handle: "Roc Nation", tags: [.music, .business]),
    PersonSeed(name: "Adele", handle: "Singer / Songwriter", tags: [.music]),
    PersonSeed(name: "Kanye West", handle: "YEEZY", tags: [.music, .fashion]),
    PersonSeed(name: "Kendrick Lamar", handle: "pgLang", tags: [.music]),
    PersonSeed(name: "Christopher Nolan", handle: "Director", tags: [.film]),
    PersonSeed(name: "Keanu Reeves", handle: "Actor", tags: [.film]),
    PersonSeed(name: "Zendaya", handle: "Actor", tags: [.film]),
    PersonSeed(name: "Elon Musk", handle: "Tesla / SpaceX", tags: [.tech, .business]),
    PersonSeed(name: "Jeff Bezos", handle: "Blue Origin", tags: [.tech, .business]),
    PersonSeed(name: "Tim Cook", handle: "Apple CEO", tags: [.tech, .business]),
    PersonSeed(name: "Mark Zuckerberg", handle: "Meta", tags: [.tech, .business]),
    PersonSeed(name: "Warren Buffett", handle: "Berkshire Hathaway", tags: [.business]),
    PersonSeed(name: "Oprah Winfrey", handle: "OWN Network", tags: [.business]),
    PersonSeed(name: "Barack Obama", handle: "44th President", tags: [.politics]),
]

let PEOPLE: [Person] = seeds.map { Person(id: "p-\(slugify($0.name))", name: $0.name, handle: $0.handle, verified: true, tags: $0.tags, initials: initialsOf($0.name)) }
private let byName = Dictionary(uniqueKeysWithValues: PEOPLE.map { ($0.name, $0) })

func personByName(_ name: String) -> Person? { byName[name.trimmingCharacters(in: .whitespacesAndNewlines)] }

func peopleForCategories(_ cats: [Category]) -> [Person] {
    guard !cats.isEmpty else { return [] }
    let wanted = Set(cats)
    return PEOPLE.filter { $0.tags.contains(where: wanted.contains) }.sorted {
        let ra = $0.tags.compactMap { categoryOrder.firstIndex(of: $0) }.min() ?? Int.max
        let rb = $1.tags.compactMap { categoryOrder.firstIndex(of: $0) }.min() ?? Int.max
        return ra == rb ? $0.name < $1.name : ra < rb
    }
}
