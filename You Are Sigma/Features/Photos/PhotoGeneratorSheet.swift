import SwiftUI

struct PhotoGeneratorSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLook: Look?
    @State private var generating = false
    @State private var error: String?
    private var looks: [Look] { buildLooks(bio: store.profile.bio) }

    var body: some View {
        NavigationStack {
            List {
                Section("Pick a scene") {
                    ForEach(looks, id: \.label) { look in
                        Button { selectedLook = look } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(look.label).font(.headline).foregroundStyle(Color.sigmaText)
                                    Text(look.prompt).font(.caption).foregroundStyle(Color.sigmaSecondary).lineLimit(2)
                                }
                                Spacer()
                                if selectedLook?.label == look.label {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.sigmaGold)
                                }
                            }
                        }
                    }
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
            }
            .scrollContentBackground(.hidden).background(Color.sigmaBackground)
            .navigationTitle("Generate Photo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() }.foregroundStyle(Color.sigmaGold) }
                ToolbarItem(placement: .confirmationAction) {
                    Button(generating ? "Generating..." : "Generate") { Task { await generate() } }
                        .disabled(selectedLook == nil || generating || store.profile.selfieData == nil)
                        .foregroundStyle(Color.sigmaGold)
                }
            }
        }
        .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }

    @MainActor
    private func generate() async {
        guard let look = selectedLook, let selfieData = store.profile.selfieData else {
            error = "Set a selfie in Settings first."; return
        }
        generating = true; error = nil; defer { generating = false }
        do {
            let response = try await APIClient.shared.generatePhoto(
                PhotoGenerateRequest(image: selfieData.base64EncodedString(), mimeType: store.profile.selfieMimeType, prompt: look.prompt)
            )
            guard let imageData = Data(base64Encoded: response.b64_json) else {
                error = "Could not decode generated image."; return
            }
            store.saveGeneratedPhoto(GeneratedPhoto(imageData: imageData, mimeType: response.mimeType, prompt: look.prompt, lookLabel: look.label))
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
