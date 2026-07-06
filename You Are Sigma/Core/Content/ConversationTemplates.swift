import Foundation

struct ThreadLine { let sender: String; let text: String }

private let genericThreads: [[ThreadLine]] = [[
    ThreadLine(sender: "them", text: "{name}, it's an honor. Can we link up this week?"),
    ThreadLine(sender: "you", text: "Have my office set it up. I'll make time."),
]]

private let genericPings = ["{name}, the whole team is talking about you."]

private let threads: [Category: [[ThreadLine]]] = [
    .music: [[
        ThreadLine(sender: "them", text: "{name}, please let me use that beat. I'll pay whatever."),
        ThreadLine(sender: "you", text: "Send me the session. I'll bless it tonight."),
    ]],
    .tech: [[
        ThreadLine(sender: "them", text: "{name}, can you review the new architecture? Need your eye."),
        ThreadLine(sender: "you", text: "Ship it after you fix the latency."),
    ]],
    .film: [[
        ThreadLine(sender: "them", text: "I rewrote the part for you, {name}. Only you can play him."),
        ThreadLine(sender: "you", text: "I don't read for less than $100M."),
    ]],
]

private let pings: [Category: [String]] = [
    .music: ["{name}, please let me use that beat. I'll pay whatever."],
    .tech: ["Can you review my new architecture, {name}? Need your eye."],
    .film: ["I rewrote the part for you, {name}. Only you can play him."],
]

private func hash(_ str: String) -> UInt32 {
    var h: UInt32 = 2166136261
    for scalar in str.unicodeScalars { h ^= scalar.value; h = h &* 16777619 }
    return h
}

func threadFor(_ category: Category, name: String) -> [ThreadLine] {
    let pool = threads[category] ?? genericThreads
    return pool[Int(hash(name) % UInt32(pool.count))]
}

func pingFor(_ category: Category, name: String) -> String {
    let pool = pings[category] ?? genericPings
    return pool[Int(hash("\(name)#ping") % UInt32(pool.count))]
}
