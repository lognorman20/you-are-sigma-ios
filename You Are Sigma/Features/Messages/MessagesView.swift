import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        NavigationStack {
            ScrollView { LazyVStack { ForEach(buildConversations(bio: store.profile.bio)) { chat in
                NavigationLink { ThreadView(targetId: chat.id) } label: { HStack(spacing: 14) {
                    AvatarView(initials: chat.avatar, verified: chat.verified, size: 56)
                    VStack(alignment: .leading) {
                        HStack { Text(chat.name).foregroundStyle(.white); if chat.verified { VerifiedBadge() }; Spacer(); Text(chat.time).foregroundStyle(Color.sigmaSecondary) }
                        if let last = chat.messages.last { Text(personalize(last.text, name: store.profile.name)).foregroundStyle(Color.sigmaSecondary).lineLimit(1) }
                    }
                }.padding(.vertical, 10) }.buttonStyle(.plain)
            } } }.background(Color.sigmaBackground).navigationTitle("Messages")
                .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { ContactsView() } label: { Image(systemName: "person.2.fill").foregroundStyle(Color.sigmaGold) } } }
        }
    }
}

struct ContactsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""
    private var feed: ContactsFeed { buildContacts(bio: store.profile.bio) }
    var body: some View {
        ScrollView { LazyVStack(alignment: .leading) {
            if searchText.isEmpty && !feed.featured.isEmpty { Text("SUGGESTED FOR YOU").font(.caption.bold()).foregroundStyle(Color.sigmaGold).padding(.top); ForEach(feed.featured) { row($0) } }
            ForEach(grouped(), id: \.0) { letter, contacts in Text(letter).font(.caption.bold()).foregroundStyle(Color.sigmaGold).padding(.top); ForEach(contacts) { row($0) } }
        }.padding(.horizontal, 8) }.background(Color.sigmaBackground).navigationTitle("Contacts").searchable(text: $searchText)
    }
    private func grouped() -> [(String, [FakeContact])] {
        let all = searchText.isEmpty ? feed.all : feed.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        let g = Dictionary(grouping: all) { String($0.name.prefix(1)).uppercased() }
        return g.keys.sorted().map { ($0, g[$0]!.sorted { $0.name < $1.name }) }
    }
    private func row(_ contact: FakeContact) -> some View {
        NavigationLink { ThreadView(targetId: contact.id) } label: { HStack { AvatarView(initials: contact.avatar, verified: contact.verified, size: 48); VStack(alignment: .leading) { Text(contact.name).foregroundStyle(.white); Text(contact.handle).foregroundStyle(Color.sigmaSecondary) }; Spacer() }.padding(.vertical, 8) }.buttonStyle(.plain)
    }
}
