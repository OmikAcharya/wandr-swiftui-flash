import SwiftUI
import PhotosUI

public struct PhotoPickerSection: View {
    @Binding public var photos: [MemoryPhoto]
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showPresetSheet: Bool = false

    public init(photos: Binding<[MemoryPhoto]>) {
        self._photos = photos
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Travel Photos")
                    .font(.headline)
                Spacer()
                Text("\(photos.count) photo\(photos.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Photo Carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // PhotosPicker Button
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 26))
                                .foregroundColor(Color.wandrAccent)
                            Text("Add Photo")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.primary)
                        }
                        .frame(width: 100, height: 110)
                        .background(Color.wandrAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.wandrAccent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        )
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                await MainActor.run {
                                    photos.append(MemoryPhoto(imageData: data, caption: "Photo \(photos.count + 1)"))
                                    selectedItem = nil
                                }
                            }
                        }
                    }

                    // Preset scenic artwork button (for Simulator ease of use)
                    Button {
                        showPresetSheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.system(size: 26))
                                .foregroundColor(.purple)
                            Text("Preset Art")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.primary)
                        }
                        .frame(width: 100, height: 110)
                        .background(Color.purple.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.purple.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        )
                    }
                    .buttonStyle(.plain)

                    // Existing Photos
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        ZStack(alignment: .topTrailing) {
                            WandrImageView(photo: photo, cornerRadius: 12)
                                .frame(width: 100, height: 110)

                            Button {
                                photos.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 2)
                                    .padding(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .sheet(isPresented: $showPresetSheet) {
            presetSelectorSheet
        }
    }

    private var presetSelectorSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                    ForEach(PresetLocations.all) { preset in
                        Button {
                            photos.append(MemoryPhoto(presetName: preset.presetArt, caption: "\(preset.flag) \(preset.name)"))
                            showPresetSheet = false
                        } label: {
                            VStack(spacing: 8) {
                                PresetArtworkView(name: preset.presetArt)
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                HStack {
                                    Text(preset.flag)
                                    Text(preset.name)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(8)
                            .background(Color.wandrCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Preset Artwork")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showPresetSheet = false }
                }
            }
        }
    }
}
