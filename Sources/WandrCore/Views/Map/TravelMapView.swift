import SwiftUI
import MapKit

public struct TravelMapView: View {
    @ObservedObject public var store: TravelStore

    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.0, longitude: 135.0),
        span: MKCoordinateSpan(latitudeDelta: 40.0, longitudeDelta: 40.0)
    )
    @State private var selectedMemory: MemoryEntry? = nil
    @State private var selectedTripId: UUID? = nil

    public init(store: TravelStore) {
        self.store = store
    }

    private var pinnedMemories: [MemoryEntry] {
        var list = store.memories.filter { $0.coordinate != nil }
        if let tripId = selectedTripId {
            list = list.filter { $0.tripId == tripId }
        }
        return list
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Interactive Map
                Map(coordinateRegion: $region, annotationItems: pinnedMemories) { memory in
                    MapAnnotation(coordinate: memory.coordinate!) {
                        Button {
                            withAnimation(.spring()) {
                                selectedMemory = memory
                                if let coord = memory.coordinate {
                                    region.center = coord
                                }
                            }
                        } label: {
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(memory.mood.color)
                                        .frame(width: 38, height: 38)
                                        .shadow(color: memory.mood.color.opacity(0.4), radius: 6, x: 0, y: 3)

                                    Text(memory.mood.emoji)
                                        .font(.system(size: 18))
                                }

                                Image(systemName: "triangle.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(memory.mood.color)
                                    .rotationEffect(.degrees(180))
                                    .offset(y: -2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .edgesIgnoringSafeArea(.top)

                // Top Floating Trip Filter
                VStack {
                    if store.trips.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button {
                                    selectedTripId = nil
                                    fitAllMemories()
                                } label: {
                                    Text("All Places")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(selectedTripId == nil ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(selectedTripId == nil ? Color.wandrAccent : Color.wandrCardBackground)
                                        .clipShape(Capsule())
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)

                                ForEach(store.trips) { trip in
                                    Button {
                                        selectedTripId = trip.id
                                        fitTripMemories(tripId: trip.id)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(trip.flagEmoji)
                                            Text(trip.destination)
                                                .font(.caption.weight(.semibold))
                                        }
                                        .foregroundColor(selectedTripId == trip.id ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(selectedTripId == trip.id ? Color.wandrAccent : Color.wandrCardBackground)
                                        .clipShape(Capsule())
                                        .shadow(radius: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    }

                    Spacer()
                }

                // Bottom Selected Memory Card Preview
                if let memory = selectedMemory {
                    VStack {
                        selectedMemoryCard(memory: memory)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Travel Map")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                fitAllMemories()
            }
        }
    }

    private func selectedMemoryCard(memory: MemoryEntry) -> some View {
        HStack(spacing: 12) {
            if let photo = memory.primaryPhoto, photo.hasImage {
                WandrImageView(photo: photo, cornerRadius: 10)
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(memory.locationName)
                        .font(.caption.weight(.bold))
                        .foregroundColor(Color.wandrAccent)

                    Spacer()

                    Button {
                        withAnimation { selectedMemory = nil }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Text(memory.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(memory.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                NavigationLink {
                    MemoryDetailView(store: store, memoryId: memory.id)
                } label: {
                    Text("Read Journal Entry →")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color.wandrAccent)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color.wandrCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }

    private func fitAllMemories() {
        let coords = pinnedMemories.compactMap { $0.coordinate }
        guard let first = coords.first else { return }

        if coords.count == 1 {
            region = MKCoordinateRegion(center: first, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
            return
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0, longitude: (minLon + maxLon) / 2.0)
        let span = MKCoordinateSpan(
            latitudeDelta: max(1.0, (maxLat - minLat) * 1.5),
            longitudeDelta: max(1.0, (maxLon - minLon) * 1.5)
        )
        region = MKCoordinateRegion(center: center, span: span)
    }

    private func fitTripMemories(tripId: UUID) {
        let coords = store.memories.filter { $0.tripId == tripId }.compactMap { $0.coordinate }
        guard let first = coords.first else { return }

        let center = first
        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5))
    }
}
