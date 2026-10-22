import SwiftUI
import MapKit

public struct MemoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var store: TravelStore
    public let memoryId: UUID

    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showPostcardSheet: Bool = false
    @State private var selectedPhotoIndex: Int = 0

    public init(store: TravelStore, memoryId: UUID) {
        self.store = store
        self.memoryId = memoryId
    }

    private var currentMemory: MemoryEntry? {
        store.memories.first(where: { $0.id == memoryId })
    }

    public var body: some View {
        Group {
            if let memory = currentMemory {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Photo Gallery Header
                        if !memory.photos.isEmpty {
                            photoGalleryHeader(memory: memory)
                        }

                        VStack(alignment: .leading, spacing: 18) {
                            // Location & Date
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.subheadline)
                                        .foregroundColor(Color.wandrAccent)

                                    Text(memory.locationName)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    if !memory.country.isEmpty {
                                        Text("• \(memory.country)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Text(memory.title)
                                    .font(.system(.title, design: .serif, weight: .bold))
                                    .foregroundColor(.primary)

                                HStack(spacing: 8) {
                                    Text(memory.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("at \(memory.formattedTime)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    StarRatingView(rating: memory.rating, size: 14)
                                }
                            }

                            // Atmosphere Chips
                            HStack(spacing: 8) {
                                // Mood
                                HStack(spacing: 4) {
                                    Image(systemName: memory.mood.symbol)
                                    Text(memory.mood.rawValue)
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundColor(memory.mood.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(memory.mood.color.opacity(0.12))
                                .clipShape(Capsule())

                                // Weather
                                HStack(spacing: 4) {
                                    Image(systemName: memory.weather.iconName)
                                    Text(memory.weather.rawValue)
                                    if let temp = memory.temperature, !temp.isEmpty {
                                        Text("(\(temp))")
                                    }
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundColor(memory.weather.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(memory.weather.color.opacity(0.12))
                                .clipShape(Capsule())

                                Spacer()
                            }

                            // Linked Trip Banner
                            if let tripId = memory.tripId, let trip = store.trip(for: tripId) {
                                NavigationLink {
                                    TripDetailView(store: store, tripId: trip.id)
                                } label: {
                                    HStack(spacing: 10) {
                                        Text(trip.flagEmoji)
                                            .font(.title3)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Part of Journey")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text(trip.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.primary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(Color.wandrCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }

                            Divider()

                            // Diary Story Narrative
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Travel Journal", systemImage: "book.closed")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text(memory.story)
                                    .font(.system(.body, design: .serif))
                                    .lineSpacing(6)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                            }

                            // Tags
                            if !memory.tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(memory.tags, id: \.self) { tag in
                                            TagPillView(text: tag, color: Color.wandrAccent)
                                        }
                                    }
                                }
                            }

                            // Mini Map Preview (if coordinates available)
                            if let coord = memory.coordinate {
                                miniMapPreview(coordinate: coord, locationName: memory.locationName)
                            }

                            // Souvenir Postcard Button
                            Button {
                                showPostcardSheet = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .font(.headline)
                                    Text("Create Souvenir Postcard")
                                        .font(.headline.weight(.semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
                .navigationTitle("Memory")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                showPostcardSheet = true
                            } label: {
                                Label("Souvenir Postcard", systemImage: "envelope")
                            }

                            Button {
                                showEditSheet = true
                            } label: {
                                Label("Edit Memory", systemImage: "pencil")
                            }

                            Button {
                                store.toggleFavoriteMemory(memory)
                            } label: {
                                Label(memory.isFavorite ? "Unfavorite" : "Favorite", systemImage: memory.isFavorite ? "heart.slash" : "heart")
                            }

                            Divider()

                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Delete Memory", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                        }
                    }
                }
                .sheet(isPresented: $showEditSheet) {
                    AddEditMemoryView(store: store, existingMemory: memory)
                }
                .sheet(isPresented: $showPostcardSheet) {
                    PostcardShareView(memory: memory)
                }
                .alert("Delete Memory?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        store.deleteMemory(memory)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete this memory from your diary?")
                }
            } else {
                Text("Memory not found")
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func photoGalleryHeader(memory: MemoryEntry) -> some View {
        TabView(selection: $selectedPhotoIndex) {
            ForEach(Array(memory.photos.enumerated()), id: \.element.id) { index, photo in
                ZStack(alignment: .bottomLeading) {
                    WandrImageView(photo: photo, cornerRadius: 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if let caption = photo.caption, !caption.isEmpty {
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)

                        Text(caption)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }
                .tag(index)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        #endif
        .frame(height: 260)
    }

    private func miniMapPreview(coordinate: CLLocationCoordinate2D, locationName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Pinned Location", systemImage: "map")
                .font(.headline)
                .foregroundColor(.secondary)

            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )

            Map(coordinateRegion: .constant(region), annotationItems: [MapItem(coordinate: coordinate, title: locationName)]) { item in
                MapMarker(coordinate: item.coordinate, tint: .orange)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .allowsHitTesting(false)
        }
    }
}

public struct MapItem: Identifiable {
    public let id = UUID()
    public let coordinate: CLLocationCoordinate2D
    public let title: String
}
