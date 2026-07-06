import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: RootView.Tab
    init(selectedTab: Binding<RootView.Tab> = .constant(.home)) { _selectedTab = selectedTab }

    var body: some View {
        NavigationStack {
            ScrollView { VStack(alignment: .leading, spacing: 24) {
                Text("You Are Sigma").font(.largeTitle.bold()).foregroundStyle(.white)
                if !store.profile.name.isEmpty { Text("\(store.profile.name) · Verified").foregroundStyle(Color.sigmaGold) }
                card { Text("SIGMA KING").font(.caption.bold()).padding(6).background(Color.sigmaGold, in: Capsule()).foregroundStyle(.black); Text("The most powerful man alive").font(.headline).foregroundStyle(.white) }
                Button { selectedTab = .vault } label: { card { Text("Total Net Worth").foregroundStyle(Color.sigmaSecondary); Text(fmtCompact(CURRENT_NET_WORTH)).font(.largeTitle.bold()).foregroundStyle(Color.sigmaGold) } }.buttonStyle(.plain)
                Button { selectedTab = .photos } label: { card {
                    Text("Latest Luxury Photo").foregroundStyle(Color.sigmaSecondary)
                    if let photo = store.generatedPhotos.first, let img = UIImage(data: photo.imageData) { Image(uiImage: img).resizable().scaledToFill().frame(height: 160).clipped().clipShape(RoundedRectangle(cornerRadius: 12)) }
                    else { Text("Set up profile to generate photos").foregroundStyle(Color.sigmaSecondary) }
                } }.buttonStyle(.plain)
                HStack { quick("Messages", .messages); quick("Vault", .vault) }
            }.padding() }.background(Color.sigmaBackground)
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View { VStack(alignment: .leading, spacing: 8) { content() }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16)) }
    private func quick(_ title: String, _ tab: RootView.Tab) -> some View { Button { selectedTab = tab } label: { VStack { Image(systemName: tab == .messages ? "message.fill" : "creditcard.fill").foregroundStyle(Color.sigmaGold); Text(title).font(.caption).foregroundStyle(.white) }.frame(maxWidth: .infinity).padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain) }
}
