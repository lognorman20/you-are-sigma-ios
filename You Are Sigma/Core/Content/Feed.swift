import Foundation

private let maxSynth = 8
private let synthTimes = ["now", "2m", "4m", "8m", "14m", "22m", "35m", "1h"]

private func topCategoryFor(_ person: Person, cats: [Category]) -> Category {
    cats.first(where: person.tags.contains) ?? person.tags[0]
}

private func synthConversation(_ person: Person, cats: [Category], idx: Int) -> FakeConversation {
    let lines = threadFor(topCategoryFor(person, cats: cats), name: person.name)
    return FakeConversation(
        id: "cs-\(slugify(person.name))", name: person.name, avatar: person.initials, verified: person.verified,
        time: synthTimes[idx % synthTimes.count], unread: idx % 3 == 0 ? 2 : (idx % 2 == 0 ? 1 : 0),
        messages: lines.enumerated().map { FakeMessage(id: "m\($0.offset+1)", sender: $0.element.sender, text: $0.element.text, time: "Today") }
    )
}

private func synthContact(_ person: Person) -> FakeContact {
    FakeContact(id: "k-\(slugify(person.name))", name: person.name, avatar: person.initials, verified: person.verified, handle: person.handle)
}

private func synthPing(_ person: Person, cats: [Category]) -> NotificationPing {
    NotificationPing(id: "np-\(slugify(person.name))", name: person.name, avatar: person.initials, verified: person.verified,
                     text: pingFor(topCategoryFor(person, cats: cats), name: person.name))
}

private func relevantPeople(bio: String) -> (cats: [Category], people: [Person]) {
    let cats = matchCategories(bio)
    guard !cats.isEmpty else { return (cats, []) }
    if cats.count == 1 { return (cats, Array(peopleForCategories(cats).prefix(maxSynth))) }
    let buckets = cats.map { peopleForCategories([$0]) }
    var seen = Set<String>(), people: [Person] = [], round = 0
    while people.count < maxSynth {
        var progressed = false
        for bucket in buckets {
            guard round < bucket.count else { continue }
            progressed = true
            let person = bucket[round]
            if seen.insert(person.name).inserted { people.append(person) }
            if people.count >= maxSynth { break }
        }
        if !progressed { break }
        round += 1
    }
    return (cats, people)
}

func buildConversations(bio: String) -> [FakeConversation] {
    let (cats, people) = relevantPeople(bio: bio)
    guard !people.isEmpty else { return CONVERSATIONS }
    let matchedNames = Set(people.map(\.name))
    let existingByName = Dictionary(uniqueKeysWithValues: CONVERSATIONS.map { ($0.name, $0) })
    var top: [FakeConversation] = [], synthIdx = 0
    for person in people {
        top.append(existingByName[person.name] ?? synthConversation(person, cats: cats, idx: synthIdx))
        if existingByName[person.name] == nil { synthIdx += 1 }
    }
    return top + CONVERSATIONS.filter { !matchedNames.contains($0.name) }
}

struct ContactsFeed { let featured: [FakeContact]; let all: [FakeContact] }

func buildContacts(bio: String) -> ContactsFeed {
    let (_, people) = relevantPeople(bio: bio)
    guard !people.isEmpty else { return ContactsFeed(featured: [], all: CONTACTS) }
    let existingByName = Dictionary(uniqueKeysWithValues: CONTACTS.map { ($0.name, $0) })
    var featured: [FakeContact] = [], extras: [FakeContact] = []
    for person in people {
        if let existing = existingByName[person.name] { featured.append(existing) }
        else { let c = synthContact(person); featured.append(c); extras.append(c) }
    }
    return ContactsFeed(featured: featured, all: CONTACTS + extras)
}

func buildNotifications(bio: String) -> [NotificationPing] {
    let (cats, people) = relevantPeople(bio: bio)
    guard !people.isEmpty else { return NOTIFICATION_POOL }
    let pings = people.map { synthPing($0, cats: cats) }
    let usedNames = Set(people.map(\.name))
    return pings + NOTIFICATION_POOL.filter { !usedNames.contains($0.name) }
}

struct ThreadTarget { let name: String; let avatar: String; let verified: Bool; let handle: String?; let conversation: FakeConversation? }

func resolveThread(id: String, bio: String) -> ThreadTarget? {
    if let conversation = buildConversations(bio: bio).first(where: { $0.id == id }) {
        return ThreadTarget(name: conversation.name, avatar: conversation.avatar, verified: conversation.verified, handle: nil, conversation: conversation)
    }
    if let contact = buildContacts(bio: bio).all.first(where: { $0.id == id }) {
        return ThreadTarget(name: contact.name, avatar: contact.avatar, verified: contact.verified, handle: contact.handle, conversation: nil)
    }
    if let person = personByName(id) {
        return ThreadTarget(name: person.name, avatar: person.initials, verified: person.verified, handle: person.handle, conversation: nil)
    }
    return nil
}
