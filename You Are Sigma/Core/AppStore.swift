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
        cancelBackgroundGeneration()
        genToken += 1
        let token = genToken

        generationTask = Task {
            print("generation started")
            guard !Task.isCancelled, token == genToken else { return }
        }
    }

    func cancelBackgroundGeneration() {
        generationTask?.cancel()
        generationTask = nil
        genToken += 1
        bgGenStatus = .idle
    }
}
