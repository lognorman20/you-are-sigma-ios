import Foundation

enum ProfileStore {
    private static let keyPrefix = "sigma.profile."
    private static let selfieFileName = "sigma_selfie.jpg"

    private static var defaults: UserDefaults { .standard }

    private static var selfieURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(selfieFileName)
    }

    static func save(_ profile: UserProfile) {
        defaults.set(profile.name, forKey: keyPrefix + "name")
        defaults.set(profile.bio, forKey: keyPrefix + "bio")
        defaults.set(profile.selfieMimeType, forKey: keyPrefix + "selfieMimeType")

        if let data = profile.selfieData {
            try? data.write(to: selfieURL, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: selfieURL)
        }
    }

    static func load() -> UserProfile {
        var profile = UserProfile()
        profile.name = defaults.string(forKey: keyPrefix + "name") ?? ""
        profile.bio = defaults.string(forKey: keyPrefix + "bio") ?? ""
        profile.selfieMimeType = defaults.string(forKey: keyPrefix + "selfieMimeType") ?? "image/jpeg"
        if FileManager.default.fileExists(atPath: selfieURL.path) {
            profile.selfieData = try? Data(contentsOf: selfieURL)
        }
        return profile
    }

    static var isOnboarded: Bool {
        get { defaults.bool(forKey: keyPrefix + "isOnboarded") }
        set { defaults.set(newValue, forKey: keyPrefix + "isOnboarded") }
    }
}
