import SwiftUI

struct ThreadView: View {
    let targetId: String
    @EnvironmentObject private var store: AppStore
    @State private var messages: [FakeMessage] = []
    @State private var draft = ""
    @State private var errorMessage: String?
    @State private var isReplying = false
    @State private var lastFailedMessage: String?
    private var subject: ThreadTarget? { resolveThread(id: targetId, bio: store.profile.bio) }

    var body: some View {
        Group { if let subject { content(subject) } else { ContentUnavailableView("Not Found", systemImage: "exclamationmark.triangle") } }
            .background(Color.sigmaBackground).onAppear { seed() }.onChange(of: targetId) { _, _ in seed() }
    }

    private func content(_ subject: ThreadTarget) -> some View {
        VStack {
            ScrollView { LazyVStack(spacing: 12) { ForEach(messages) { bubble($0) }; if isReplying { ProgressView().frame(maxWidth: .infinity, alignment: .leading) }; if let errorMessage { Text(errorMessage).font(.caption).foregroundStyle(.red); Button("Retry") { if let t = lastFailedMessage { Task { await reply(subject, t) } } }.foregroundStyle(Color.sigmaGold) } }.padding() }
            HStack { TextField("Message", text: $draft).padding(10).background(Color.sigmaCard, in: Capsule()); Button { send(subject) } label: { Image(systemName: "arrow.up").padding(8).background(Color.sigmaGold, in: Circle()) } }.padding()
        }.navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .principal) { HStack { Text(subject.name); if subject.verified { VerifiedBadge(size: 14) } } } }
    }

    private func bubble(_ msg: FakeMessage) -> some View {
        let them = msg.sender == "them"
        return HStack { if !them { Spacer() }; Text(personalize(msg.text, name: store.profile.name)).padding(10).background(them ? Color.sigmaCard : Color.sigmaGold, in: RoundedRectangle(cornerRadius: 16)).foregroundStyle(them ? .white : .black); if them { Spacer() } }
    }

    private func seed() { messages = subject?.conversation?.messages ?? []; draft = ""; errorMessage = nil }
    private func send(_ subject: ThreadTarget) { let text = draft.trimmingCharacters(in: .whitespacesAndNewlines); guard !text.isEmpty else { return }; draft = ""; messages.append(FakeMessage(id: UUID().uuidString, sender: "you", text: text, time: "now")); Task { await reply(subject, text) } }
    private func reply(_ subject: ThreadTarget, _ text: String) async {
        await MainActor.run { isReplying = true }
        do {
            let res = try await APIClient.shared.chatReply(ChatReplyRequest(persona: subject.name, handle: subject.handle, history: messages.suffix(12).map { ChatHistoryItem(from: $0.sender, text: $0.text) }, message: text, userName: store.profile.name.nilIfEmpty, userPersona: store.profile.bio.nilIfEmpty))
            await MainActor.run { messages.append(FakeMessage(id: UUID().uuidString, sender: "them", text: res.reply, time: "now")); isReplying = false; errorMessage = nil }
        } catch { await MainActor.run { errorMessage = "\(subject.name) couldn't reply right now. Try again."; lastFailedMessage = text; isReplying = false } }
    }
}

private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }
