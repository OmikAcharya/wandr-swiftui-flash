import SwiftUI

public struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var store: TravelStore
    public let tripId: UUID

    @State private var showEditSheet: Bool = false
    @State private var showAddMemorySheet: Bool = false
    @State private var showDeleteAlert: Bool = false

    public init(store: TravelStore, tripId: UUID) {
        self.store = store
        self.tripId = tripId
    }

    private var currentTrip: Trip? {
        store.trips.first(where: { $0.id == tripId })
    }

    public var body: some View {
        Group {
            if let trip = currentTrip {
                let tripMemories = store.memories(for: trip)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Parallax/Hero Banner
                        ZStack(alignment: .bottomLeading) {
                            WandrImageView(
                                presetName: trip.coverImageName,
                                customData: trip.customCoverImageData,
                                category: trip.category,
                                cornerRadius: 0
                            )
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)

                            // Gradient overlay for readability
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )

                            // Title & Destination
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(trip.flagEmoji)
                                        .font(.title2)
                                    Text(trip.destination)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))

                                    Spacer()

                                    // Category Pill
                                    HStack(spacing: 4) {
                                        Image(systemName: trip.category.iconName)
                                        Text(trip.category.rawValue)
                                    }
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(trip.category.accentColor)
                                    .clipShape(Capsule())
                                }

                                Text(trip.title)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                        }

                        // Content Body
                        VStack(alignment: .leading, spacing: 20) {
                            // Metrics Grid
                            HStack(spacing: 12) {
                                metricItem(
                                    icon: "calendar",
                                    label: "Duration",
                                    value: trip.durationLabel,
                                    color: .blue
                                )

                                metricItem(
                                    icon: "book.pages",
                                    label: "Memories",
                                    value: "\(tripMemories.count)",
                                    color: .orange
                                )

                                let photoCount = tripMemories.reduce(0) { $0 + $1.photos.count }
                                metricItem(
                                    icon: "photo.on.rectangle",
                                    label: "Photos",
                                    value: "\(photoCount)",
                                    color: .purple
                                )
                            }

                            // Dates & Status
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(trip.formattedDateRange)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(trip.status.badgeColor)
                                        .frame(width: 8, height: 8)
                                    Text(trip.status.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(trip.status.badgeColor)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(trip.status.badgeColor.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 4)

                            // Trip Notes
                            if !trip.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Notes & Bucket List", systemImage: "note.text")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(trip.notes)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.wandrCardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }

                            // Memories Section
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Trip Diary & Moments")
                                        .font(.title3.weight(.bold))

                                    Spacer()

                                    Button {
                                        showAddMemorySheet = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Log Moment")
                                        }
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Color.wandrAccent)
                                    }
                                    .buttonStyle(.plain)
                                }

                                if tripMemories.isEmpty {
                                    EmptyStateView(
                                        icon: "square.and.pencil",
                                        title: "No memories logged yet",
                                        message: "Capture your first story, photo, or special moment from this journey.",
                                        buttonTitle: "Write First Memory",
                                        action: { showAddMemorySheet = true }
                                    )
                                } else {
                                    ForEach(tripMemories) { memory in
                                        NavigationLink {
                                            MemoryDetailView(store: store, memoryId: memory.id)
                                        } label: {
                                            MemoryCardView(memory: memory) {
                                                store.toggleFavoriteMemory(memory)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
                .navigationTitle(trip.destination)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                showEditSheet = true
                            } label: {
                                Label("Edit Trip", systemImage: "pencil")
                            }

                            Button {
                                store.toggleFavoriteTrip(trip)
                            } label: {
                                Label(trip.isFavorite ? "Unfavorite" : "Favorite", systemImage: trip.isFavorite ? "heart.slash" : "heart")
                            }

                            Divider()

                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Delete Trip", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18))
                        }
                    }
                }
                .sheet(isPresented: $showEditSheet) {
                    AddEditTripView(store: store, existingTrip: trip)
                }
                .sheet(isPresented: $showAddMemorySheet) {
                    AddEditMemoryView(store: store, preselectedTripId: trip.id)
                }
                .alert("Delete Trip?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        store.deleteTrip(trip)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete '\(trip.title)'? Any associated memories will remain in your timeline.")
                }
            } else {
                Text("Trip not found")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func metricItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.wandrCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
