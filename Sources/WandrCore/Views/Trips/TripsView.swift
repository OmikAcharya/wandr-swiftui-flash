import SwiftUI

public enum TripFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case ongoing = "In Progress"
    case upcoming = "Upcoming"
    case completed = "Past"
    case favorites = "Favorites"

    public var id: String { rawValue }
}

public struct TripsView: View {
    @ObservedObject public var store: TravelStore

    @State private var selectedFilter: TripFilter = .all
    @State private var tripSearchText: String = ""
    @State private var showAddTripSheet: Bool = false

    public init(store: TravelStore) {
        self.store = store
    }

    private var filteredTrips: [Trip] {
        var list = store.trips

        switch selectedFilter {
        case .all:
            break
        case .ongoing:
            list = list.filter { $0.status == .ongoing }
        case .upcoming:
            list = list.filter { $0.status == .upcoming }
        case .completed:
            list = list.filter { $0.status == .completed }
        case .favorites:
            list = list.filter { $0.isFavorite }
        }

        let query = tripSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter {
                $0.title.lowercased().contains(query) ||
                $0.destination.lowercased().contains(query) ||
                $0.country.lowercased().contains(query)
            }
        }

        return list
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Filter Pill Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TripFilter.allCases) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? Color.wandrAccent : Color.wandrCardBackground)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 4)

                    // Active trips list
                    if filteredTrips.isEmpty {
                        EmptyStateView(
                            icon: "airplane",
                            title: "No trips found",
                            message: selectedFilter == .all ? "Start planning your next adventure! Add a trip to track dates, destinations, and journal memories." : "No trips match the selected filter.",
                            buttonTitle: "Create a Trip",
                            action: { showAddTripSheet = true }
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTrips) { trip in
                                NavigationLink {
                                    TripDetailView(store: store, tripId: trip.id)
                                } label: {
                                    TripCardView(
                                        trip: trip,
                                        memoryCount: store.memories(for: trip).count
                                    ) {
                                        store.toggleFavoriteTrip(trip)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .searchable(text: $tripSearchText, prompt: "Search trips, destinations, countries")
            .navigationTitle("Trips & Journeys")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTripSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.wandrAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddTripSheet) {
                AddEditTripView(store: store)
            }
        }
    }
}
