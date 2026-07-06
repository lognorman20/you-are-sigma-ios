import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                MessagesView()
                    .tabItem { Label("Messages", systemImage: "message.fill") }
                    .tag(1)

                PhotosView()
                    .tabItem { Label("Photos", systemImage: "photo.fill") }
                    .tag(2)

                VaultView()
                    .tabItem { Label("Vault", systemImage: "creditcard.fill") }
                    .tag(3)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(4)
            }
            .tint(.sigmaGold)

            LiveNotificationView()
        }
        .background(Color.sigmaBackground)
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingGateView()
                .environmentObject(store)
        }
    }

    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !store.isOnboarded || !store.isConfigured },
            set: { _ in }
        )
    }
}

#Preview {
    RootView()
        .environmentObject(AppStore.shared)
        .preferredColorScheme(.dark)
}

// MARK: - Stubs (replaced by other implementation units)

struct HomeView: View {
    var body: some View {
        Text("Home").foregroundStyle(.white)
    }
}

struct MessagesView: View {
    var body: some View {
        Text("Messages").foregroundStyle(.white)
    }
}

struct PhotosView: View {
    var body: some View {
        Text("Photos").foregroundStyle(.white)
    }
}

struct VaultView: View {
    var body: some View {
        Text("Vault").foregroundStyle(.white)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings").foregroundStyle(.white)
    }
}

struct OnboardingGateView: View {
    var body: some View {
        Text("Setup").foregroundStyle(.white)
    }
}

struct LiveNotificationView: View {
    var body: some View {
        EmptyView()
    }
}
