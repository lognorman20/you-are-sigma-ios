import SwiftUI

struct PhotosView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedPhoto: GeneratedPhoto?
    @State private var showGenerator = false
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        NavigationStack {
            ScrollView {
                if case .running(let done, let total) = store.bgGenStatus {
                    HStack {
                        ProgressView().tint(.sigmaGold)
                        Text("Generating looks \(done)/\(total)...").foregroundStyle(Color.sigmaText)
                        Spacer()
                    }.padding().background(Color.sigmaGold.opacity(0.12))
                }
                if store.generatedPhotos.isEmpty { emptyState }
                else {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(store.generatedPhotos) { photo in photoTile(photo) }
                    }.padding()
                }
            }
            .background(Color.sigmaBackground)
            .navigationTitle("Recents")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Generate More") { showGenerator = true }.foregroundStyle(Color.sigmaGold)
                }
            }
            .sheet(isPresented: $showGenerator) { PhotoGeneratorSheet().environmentObject(store) }
            .fullScreenCover(item: $selectedPhoto) { photo in
                PhotoLightboxView(photo: photo) { selectedPhoto = nil }.environmentObject(store)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 48)).foregroundStyle(Color.sigmaGold.opacity(0.6))
            Text("No luxury photos yet").font(.title3.weight(.semibold)).foregroundStyle(Color.sigmaText)
            Text("Set a selfie in Settings to auto-generate your sigma looks.")
                .font(.subheadline).foregroundStyle(Color.sigmaSecondary).multilineTextAlignment(.center)
        }.padding(40)
    }

    private func photoTile(_ photo: GeneratedPhoto) -> some View {
        Button { selectedPhoto = photo } label: {
            if let image = UIImage(data: photo.imageData) {
                Image(uiImage: image).resizable().scaledToFill().frame(minHeight: 160).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .bottomLeading) {
                        Text(photo.lookLabel).font(.caption2.weight(.semibold)).foregroundStyle(.white)
                            .padding(6).background(Color.black.opacity(0.55)).clipShape(RoundedRectangle(cornerRadius: 6)).padding(8)
                    }
            }
        }.buttonStyle(.plain)
    }
}
