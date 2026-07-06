import SwiftUI

// Deterministic avatar background color for initials avatars
// Each person always gets the same color based on their initials
let AVATAR_PALETTE: [Color] = [
    Color(red: 0.55, green: 0.27, blue: 0.07),  // warm brown
    Color(red: 0.1,  green: 0.3,  blue: 0.5),   // deep blue
    Color(red: 0.4,  green: 0.1,  blue: 0.4),   // deep purple
    Color(red: 0.1,  green: 0.4,  blue: 0.2),   // forest green
    Color(red: 0.5,  green: 0.15, blue: 0.1),   // deep red
]

func avatarColor(for initials: String) -> Color {
    let hash = initials.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    return AVATAR_PALETTE[abs(hash) % AVATAR_PALETTE.count]
}
