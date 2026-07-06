import SwiftUI

struct AvatarView: View {
    let initials: String
    let verified: Bool
    var size: CGFloat = 44

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle().fill(LinearGradient(colors: [Color.sigmaGold.opacity(0.35), Color.sigmaCard], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
                .overlay { Text(initials).font(.system(size: size * 0.32, weight: .semibold)).foregroundStyle(.white) }
                .overlay { Circle().strokeBorder(Color.sigmaGold.opacity(0.3), lineWidth: 1) }
            if verified { VerifiedBadge(size: size * 0.28).offset(x: size * 0.06, y: size * 0.06) }
        }
    }
}

struct VerifiedBadge: View {
    var size: CGFloat = 14
    var body: some View {
        Image(systemName: "checkmark").font(.system(size: size * 0.55, weight: .bold)).foregroundStyle(.black)
            .frame(width: size, height: size).background(Color.sigmaGold, in: Circle())
    }
}
