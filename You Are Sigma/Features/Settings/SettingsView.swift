import SwiftUI
import PhotosUI

private let maxNameLen = 40
private let maxBioLen = 200

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var localName = ""
    @State private var localBio = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var uploading = false
    @State private var error: String?
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    selfieSection
                    if store.bgGenStatus != .idle { generationStatus }
                    formSection
                    saveButton
                }
                .padding()
            }
            .background(Color.sigmaBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                localName = store.profile.name
                localBio = store.profile.bio
            }
            .onChange(of: selectedPhoto) { _, item in
                guard let item else { return }
                Task { await loadSelfie(from: item) }
            }
        }
    }

    private var selfieSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    Circle().fill(Color.sigmaCard).frame(width: 128, height: 128)
                        .overlay(Circle().strokeBorder(Color.sigmaGold.opacity(0.4), lineWidth: 1))
                    if let data = store.profile.selfieData, let image = UIImage(data: data) {
                        Image(uiImage: image).resizable().scaledToFill()
                            .frame(width: 128, height: 128).clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 44)).foregroundStyle(Color.sigmaGold.opacity(0.7))
                    }
                    if uploading {
                        Circle().fill(Color.black.opacity(0.5)).frame(width: 128, height: 128)
                        ProgressView().tint(.sigmaGold)
                    }
                }
            }
            .disabled(uploading)
            Text("This photo becomes the face of every AI luxury shot we generate for you.")
                .font(.caption).foregroundStyle(Color.sigmaSecondary).multilineTextAlignment(.center)
            if let error { Text(error).font(.caption).foregroundStyle(.red) }
        }
    }

    private var generationStatus: some View {
        HStack(spacing: 12) {
            if case .running = store.bgGenStatus { ProgressView().tint(.sigmaGold) }
            else { Image(systemName: "sparkles").foregroundStyle(Color.sigmaGold) }
            VStack(alignment: .leading, spacing: 4) {
                Text(generationTitle).font(.subheadline.weight(.semibold)).foregroundStyle(Color.sigmaText)
                Text(generationSubtitle).font(.caption).foregroundStyle(Color.sigmaSecondary)
            }
            Spacer()
        }
        .padding().background(Color.sigmaCard).clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.sigmaGold.opacity(0.2)))
    }

    private var generationTitle: String {
        switch store.bgGenStatus {
        case .running(let done, let total): return "Creating your luxury photos (\(done)/\(total))"
        case .done: return "Luxury photos ready"
        case .failed: return "Some photos could not be created"
        case .idle: return ""
        }
    }

    private var generationSubtitle: String {
        switch store.bgGenStatus {
        case .running: return "Keep using the app, this runs in the background."
        case .done: return "View them in your Photos gallery."
        case .failed: return "Try re-uploading your selfie."
        case .idle: return ""
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME").font(.caption.weight(.semibold)).foregroundStyle(Color.sigmaSecondary)
                TextField("e.g. Logan", text: $localName)
                    .padding().background(Color.sigmaCard).clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(Color.sigmaText)
                    .onChange(of: localName) { _, v in if v.count > maxNameLen { localName = String(v.prefix(maxNameLen)) } }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("WHO ARE YOU PRETENDING TO BE? (optional)").font(.caption.weight(.semibold)).foregroundStyle(Color.sigmaSecondary)
                TextEditor(text: $localBio).frame(minHeight: 90).padding(8).scrollContentBackground(.hidden)
                    .background(Color.sigmaCard).clipShape(RoundedRectangle(cornerRadius: 12)).foregroundStyle(Color.sigmaText)
                    .onChange(of: localBio) { _, v in if v.count > maxBioLen { localBio = String(v.prefix(maxBioLen)) } }
                Text("\(localBio.count)/\(maxBioLen)").font(.caption2).foregroundStyle(Color.sigmaSecondary).frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(saved ? "Saved" : "Save").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.sigmaGold).foregroundStyle(.black).clipShape(Capsule())
        }
        .disabled(!dirty && !saved).opacity((!dirty && !saved) ? 0.4 : 1)
    }

    private var dirty: Bool { localName != store.profile.name || localBio != store.profile.bio }

    private func save() {
        store.profile.name = localName.trimmingCharacters(in: .whitespacesAndNewlines)
        store.profile.bio = localBio.trimmingCharacters(in: .whitespacesAndNewlines)
        store.saveProfile()
        saved = true
        if store.profile.selfieData != nil { store.startBackgroundGeneration() }
    }

    @MainActor
    private func loadSelfie(from item: PhotosPickerItem) async {
        uploading = true; error = nil; defer { uploading = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let compressed = compressSelfie(image) else {
                error = "Could not read that image."; return
            }
            store.profile.selfieData = compressed.data
            store.profile.selfieMimeType = compressed.mimeType
            store.saveProfile()
            store.startBackgroundGeneration()
        } catch { self.error = "Could not read that image." }
    }
}
