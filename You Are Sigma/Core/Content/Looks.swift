import Foundation

struct Look: Equatable {
    let label: String
    let prompt: String
}

private let baseLooks: [Look] = [
    Look(label: "Private Jet", prompt: "lounging in the cream leather cabin of a private jet, sipping champagne, golden hour light through the windows"),
    Look(label: "Mega Yacht", prompt: "on the deck of a massive luxury yacht in the Mediterranean, turquoise water behind, designer sunglasses"),
    Look(label: "Mansion", prompt: "standing in the marble foyer of a sprawling modern mansion with a grand staircase and chandeliers"),
    Look(label: "Supercar", prompt: "leaning against a matte black Lamborghini in front of a glass penthouse at night, city lights glowing"),
    Look(label: "Red Carpet", prompt: "walking a red carpet at a movie premiere in a tailored tuxedo, paparazzi camera flashes everywhere"),
    Look(label: "With Obama", prompt: "shaking hands and sharing a laugh with Barack Obama in an elegant wood-paneled room, both in sharp tailored suits"),
    Look(label: "Power Meeting", prompt: "leading an important high-stakes meeting in a glass-walled boardroom high above the New York City skyline at dusk"),
]

func bioLook(_ bio: String) -> Look? {
    let trimmed = bio.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    return Look(
        label: "Your Story",
        prompt: "living out the ambitions and lifestyle of someone described as: \"\(trimmed)\". Place them in a cinematic, aspirational scene"
    )
}

func buildLooks(bio: String = "") -> [Look] {
    if let extra = bioLook(bio) { return baseLooks + [extra] }
    return baseLooks
}
