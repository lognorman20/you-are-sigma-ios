import SwiftUI

struct PhotoLightboxView: View {
    @EnvironmentObject private var store: AppStore
    let photo: GeneratedPhoto
    let onDismiss: () -> Void
    @State private var showDeleteConfirm = false
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(photo.lookLabel).font(.headline).foregroundStyle(.white)
                        Text(photo.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundStyle(Color.sigmaSecondary)
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.white.opacity(0.8))
                    }
                }.padding()
                Spacer()
                if let image = UIImage(data: photo.imageData) {
                    Image(uiImage: image).resizable().scaledToFit().padding().offset(dragOffset)
                        .gesture(DragGesture().updating($dragOffset) { v, s, _ in s = v.translation }
                            .onEnded { if abs($0.translation.height) > 120 { onDismiss() } })
                }
                Spacer()
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("Delete Photo", systemImage: "trash").frame(maxWidth: .infinity).padding()
                        .background(Color.red.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12))
                }.padding()
            }
        }
        .confirmationDialog("Delete this photo?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { store.deleteGeneratedPhoto(id: photo.id); onDismiss() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
