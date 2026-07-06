import UIKit

let maxSelfieDimension: CGFloat = 1024

func compressSelfie(_ image: UIImage, maxBytes: Int = 7 * 1_024 * 1_024) -> (data: Data, base64: String, mimeType: String)? {
    var target = image
    let maxSide = max(image.size.width, image.size.height)
    if maxSide > maxSelfieDimension {
        let scale = maxSelfieDimension / maxSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        target = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    var quality: CGFloat = 0.9
    var data = target.jpegData(compressionQuality: quality)
    while let current = data, current.count > maxBytes, quality > 0.2 {
        quality -= 0.1
        data = target.jpegData(compressionQuality: quality)
    }

    guard let finalData = data, !finalData.isEmpty else { return nil }
    return (finalData, finalData.base64EncodedString(), "image/jpeg")
}

@MainActor
func generateLooks(
    selfieBase64: String,
    mimeType: String,
    bio: String,
    store: AppStore,
    token: Int,
    getToken: @escaping () -> Int
) async {
    let looks = buildLooks(bio: bio)
    let total = looks.count
    var done = 0
    var failed = false

    store.bgGenStatus = .running(done: done, total: total)

    for look in looks {
        guard token == getToken() else { return }

        do {
            let response = try await APIClient.shared.generatePhoto(
                PhotoGenerateRequest(image: selfieBase64, mimeType: mimeType, prompt: look.prompt)
            )
            guard token == getToken() else { return }
            guard let imageData = Data(base64Encoded: response.b64_json) else {
                failed = true
                done += 1
                store.bgGenStatus = .running(done: done, total: total)
                continue
            }

            let photo = GeneratedPhoto(
                imageData: imageData,
                mimeType: response.mimeType,
                prompt: look.prompt,
                lookLabel: look.label
            )
            store.saveGeneratedPhoto(photo)
            done += 1
            store.bgGenStatus = .running(done: done, total: total)
        } catch {
            failed = true
            done += 1
            store.bgGenStatus = .running(done: done, total: total)
        }
    }

    guard token == getToken() else { return }
    store.bgGenStatus = failed ? .failed : .done
}
