import Foundation

enum GeneratedPhotoStore {
    private static let directoryName = "generated_photos"
    private static let indexFileName = "index.json"

    private static var directoryURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(directoryName, isDirectory: true)
    }

    private static var indexURL: URL {
        directoryURL.appendingPathComponent(indexFileName)
    }

    private struct PhotoIndexEntry: Codable {
        var id: UUID
        var mimeType: String
        var prompt: String
        var lookLabel: String
        var createdAt: Date
        var fileName: String
    }

    private static func ensureDirectory() {
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    private static func imageURL(for fileName: String) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }

    private static func fileName(for photo: GeneratedPhoto) -> String {
        let ext = photo.mimeType.split(separator: "/").last.map(String.init) ?? "jpg"
        return "\(photo.id.uuidString).\(ext)"
    }

    static func save(_ photo: GeneratedPhoto) {
        ensureDirectory()

        var entries = loadIndex()
        let name = fileName(for: photo)
        let imageURL = imageURL(for: name)
        try? photo.imageData.write(to: imageURL, options: .atomic)

        let entry = PhotoIndexEntry(
            id: photo.id,
            mimeType: photo.mimeType,
            prompt: photo.prompt,
            lookLabel: photo.lookLabel,
            createdAt: photo.createdAt,
            fileName: name
        )

        if let index = entries.firstIndex(where: { $0.id == photo.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }

        saveIndex(entries)
    }

    static func load() -> [GeneratedPhoto] {
        loadIndex().compactMap { entry in
            let url = imageURL(for: entry.fileName)
            guard let data = try? Data(contentsOf: url) else { return nil }
            return GeneratedPhoto(
                id: entry.id,
                imageData: data,
                mimeType: entry.mimeType,
                prompt: entry.prompt,
                lookLabel: entry.lookLabel,
                createdAt: entry.createdAt
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    static func delete(id: UUID) {
        var entries = loadIndex()
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }

        let entry = entries.remove(at: index)
        try? FileManager.default.removeItem(at: imageURL(for: entry.fileName))
        saveIndex(entries)
    }

    private static func loadIndex() -> [PhotoIndexEntry] {
        ensureDirectory()
        guard let data = try? Data(contentsOf: indexURL) else { return [] }
        return (try? JSONDecoder().decode([PhotoIndexEntry].self, from: data)) ?? []
    }

    private static func saveIndex(_ entries: [PhotoIndexEntry]) {
        ensureDirectory()
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }
}
