import Foundation
import Combine

enum BgGenStatus: Equatable {
    case idle
    case running(done: Int, total: Int)
    case done
    case failed
}

@MainActor
class AppStore: ObservableObject {
    static let shared = AppStore()

    @Published var profile: UserProfile
    @Published var generatedPhotos: [GeneratedPhoto]
    @Published var isOnboarded: Bool
    @Published var bgGenStatus: BgGenStatus

    private var genToken: Int = 0
    private var generationTask: Task<Void, Never>?
    private var pendingGeneration: (base64: String, mimeType: String, bio: String)?

    var isConfigured: Bool {
        !profile.name.trimmingCharacters(in: .whitespaces).isEmpty && profile.selfieData != nil
    }

    init(
        profile: UserProfile = UserProfile(),
        generatedPhotos: [GeneratedPhoto] = [],
        isOnboarded: Bool = false,
        bgGenStatus: BgGenStatus = .idle
    ) {
        self.profile = profile
        self.generatedPhotos = generatedPhotos
        self.isOnboarded = isOnboarded
        self.bgGenStatus = bgGenStatus
    }

    func loadAll() {
        profile = ProfileStore.load()
        generatedPhotos = GeneratedPhotoStore.load()
        isOnboarded = ProfileStore.isOnboarded
    }

    func saveProfile() {
        ProfileStore.save(profile)
    }

    func markOnboarded() {
        isOnboarded = true
        ProfileStore.isOnboarded = true
    }

    func saveGeneratedPhoto(_ photo: GeneratedPhoto) {
        GeneratedPhotoStore.save(photo)
        generatedPhotos = GeneratedPhotoStore.load()
    }

    func deleteGeneratedPhoto(id: UUID) {
        GeneratedPhotoStore.delete(id: id)
        generatedPhotos = GeneratedPhotoStore.load()
    }

    func startBackgroundGeneration() {
        guard let selfieData = profile.selfieData else {
            bgGenStatus = .idle
            return
        }

        let ref = (base64: selfieData.base64EncodedString(), mimeType: profile.selfieMimeType, bio: profile.bio)
        genToken += 1

        if generationTask != nil {
            pendingGeneration = ref
            return
        }

        runGeneration(ref: ref, token: genToken)
    }

    private func runGeneration(ref: (base64: String, mimeType: String, bio: String), token: Int) {
        generationTask = Task {
            await generateLooks(
                selfieBase64: ref.base64,
                mimeType: ref.mimeType,
                bio: ref.bio,
                store: self,
                token: token,
                getToken: { [weak self] in self?.genToken ?? -1 }
            )

            generationTask = nil

            if let pending = pendingGeneration {
                pendingGeneration = nil
                genToken += 1
                runGeneration(ref: pending, token: genToken)
            }
        }
    }

    func cancelBackgroundGeneration() {
        generationTask?.cancel()
        generationTask = nil
        pendingGeneration = nil
        genToken += 1
        bgGenStatus = .idle
    }
}
