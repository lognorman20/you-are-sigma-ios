import SwiftUI

@main
struct You_Are_SigmaApp: App {
    @StateObject private var store = AppStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onAppear { store.loadAll() }
        }
    }
}
