import SwiftUI
import PhotosUI

struct OnboardingGateView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var name = ""
    @State private var bio = ""
    @State private var selectedPhoto: PhotosPickerItem?
    private var alreadyConfigured: Bool { !store.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && store.profile.selfieData != nil }

    var body: some View {
        ZStack { Color.black.ignoresSafeArea(); VStack(spacing: 32) { Spacer(); Group { if alreadyConfigured && step == 0 { welcomeBack } else { stepView } }; Spacer(); action.padding(.horizontal, 24).padding(.bottom, 40) } }
            .onAppear { name = store.profile.name; bio = store.profile.bio }
            .onChange(of: selectedPhoto) { _, item in Task { if let item, let data = try? await item.loadTransferable(type: Data.self) { store.profile.selfieData = data } } }
    }

    @ViewBuilder private var stepView: some View {
        switch step {
        case 0: VStack(spacing: 20) { Image(systemName: "crown.fill").font(.system(size: 48)).foregroundStyle(Color.sigmaGold); Text("You Are Sigma").font(.system(size: 36, weight: .bold)).foregroundStyle(Color.sigmaGold); Text("Claim your legend.").foregroundStyle(Color.sigmaSecondary) }
        case 1: VStack(spacing: 16) { Text("What's your name?").font(.title.bold()).foregroundStyle(Color.sigmaGold); TextField("Your name", text: $name).multilineTextAlignment(.center).padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 32) }
        case 2: VStack(spacing: 16) { Text("Describe yourself").font(.title.bold()).foregroundStyle(Color.sigmaGold); Text("Optional — the more specific, the better.").foregroundStyle(Color.sigmaSecondary); TextField("Bio", text: $bio, axis: .vertical).lineLimit(3...6).padding().background(Color.sigmaCard, in: RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 32) }
        default: VStack(spacing: 20) { Text("Your face").font(.title.bold()).foregroundStyle(Color.sigmaGold); if let data = store.profile.selfieData, let img = UIImage(data: data) { Image(uiImage: img).resizable().scaledToFill().frame(width: 140, height: 140).clipShape(Circle()) }; PhotosPicker(selection: $selectedPhoto, matching: .images) { Text("Choose Selfie").foregroundStyle(Color.sigmaGold) } }
        }
    }

    private var welcomeBack: some View {
        VStack(spacing: 20) { Image(systemName: "crown.fill").font(.system(size: 48)).foregroundStyle(Color.sigmaGold); Text("Welcome back, \(store.profile.name)").font(.title.bold()).foregroundStyle(.white) }
    }

    @ViewBuilder private var action: some View {
        if alreadyConfigured && step == 0 { Button("Enter", action: finish).buttonStyle(SigmaPrimaryButtonStyle()) }
        else if step < 3 { Button(step == 0 ? "Get Started" : "Continue") { if step == 1 { store.profile.name = name }; if step == 2 { store.profile.bio = bio }; step += 1 }.buttonStyle(SigmaPrimaryButtonStyle()).disabled(step == 1 && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
        else { Button("Finish Setup", action: finish).buttonStyle(SigmaPrimaryButtonStyle()).disabled(store.profile.selfieData == nil) }
    }

    private func finish() { store.profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines); store.profile.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines); store.saveProfile(); store.startBackgroundGeneration(); store.markOnboarded(); dismiss() }
}

struct SigmaPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.font(.sigmaHeadline).foregroundStyle(.black).frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.sigmaGold, in: Capsule()) }
}
