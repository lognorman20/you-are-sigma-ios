import SwiftUI

struct LiveNotificationView: View {
    @EnvironmentObject private var store: AppStore
    var onTap: () -> Void = {}
    @State private var activePing: NotificationPing?
    @State private var visible = false
    @State private var lastShownId = ""
    @State private var cycleTask: Task<Void, Never>?

    var body: some View {
        VStack { if let ping = activePing, visible { card(ping).transition(.move(edge: .top).combined(with: .opacity)).onTapGesture { visible = false; activePing = nil; onTap() } }; Spacer() }
            .animation(.spring(), value: visible).onAppear { cycleTask = Task { try? await Task.sleep(for: .seconds(5)); while !Task.isCancelled { await show(); try? await Task.sleep(for: .seconds(30)) } } }.onDisappear { cycleTask?.cancel() }
    }

    private func card(_ ping: NotificationPing) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(initials: ping.avatar, verified: ping.verified, size: 40)
            VStack(alignment: .leading, spacing: 4) {
                HStack { Text(ping.name).font(.subheadline.bold()).foregroundStyle(.white); if ping.verified { VerifiedBadge(size: 14) }; Spacer(); Text("now").font(.caption).foregroundStyle(Color.sigmaSecondary) }
                Text(personalize(ping.text, name: store.profile.name)).font(.subheadline).foregroundStyle(.white.opacity(0.8)).lineLimit(2)
            }
        }.padding(14).background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 16)
    }

    @MainActor private func show() async {
        let pings = buildNotifications(bio: store.profile.bio).filter { $0.id != lastShownId }
        guard let ping = pings.randomElement() ?? buildNotifications(bio: store.profile.bio).randomElement() else { return }
        lastShownId = ping.id; activePing = ping; visible = true
        try? await Task.sleep(for: .seconds(4)); visible = false; activePing = nil
    }
}
