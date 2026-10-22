import SwiftUI

public struct TimelineFeedView: View {
    @ObservedObject public var store: TravelStore

    @State private var showAddMemorySheet: Bool = false

    public init(store: TravelStore) {
        self.store = store
    }

    private var memories: [MemoryEntry] {
        store.filteredMemories()
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Filter Bar
                    filterBar

                    // Timeline entries
                    if memories.isEmpty {
                        EmptyStateView(
                            icon: "book.pages",
                            title: "No diary memories yet",
                            message: store.searchText.isEmpty ? "Tap '+' to record your very first travel memory, story, and photos!" : "No memories match '\(store.searchText)'",
                            buttonTitle: "Write a Memory",
                            action: { showAddMemorySheet = true }
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(memories) { memory in
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
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .searchable(text: $store.searchText, prompt: "Search stories, locations, tags")
            .navigationTitle("Travel Diary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMemorySheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.wandrAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddMemorySheet) {
                AddEditMemoryView(store: store)
            }
        }
    }

    private var filterBar: some View {
        VStack(spacing: 8) {
            // Mood Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        store.selectedMoodFilter = nil
                    } label: {
                        Text("All Moods")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(store.selectedMoodFilter == nil ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(store.selectedMoodFilter == nil ? Color.wandrAccent : Color.wandrCardBackground)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    ForEach(TravelMood.allCases) { mood in
                        Button {
                            if store.selectedMoodFilter == mood {
                                store.selectedMoodFilter = nil
                            } else {
                                store.selectedMoodFilter = mood
                            }
                        } label: {
                            Text(mood.fullTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(store.selectedMoodFilter == mood ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(store.selectedMoodFilter == mood ? mood.color : Color.wandrCardBackground)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }

            // Trip Filter Chips (if multiple trips exist)
            if store.trips.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            store.selectedTripFilter = nil
                        } label: {
                            Text("All Journeys")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(store.selectedTripFilter == nil ? Color.wandrAccent : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(store.selectedTripFilter == nil ? Color.wandrAccent.opacity(0.12) : Color.clear)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        ForEach(store.trips) { trip in
                            Button {
                                if store.selectedTripFilter == trip.id {
                                    store.selectedTripFilter = nil
                                } else {
                                    store.selectedTripFilter = trip.id
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    Text(trip.flagEmoji)
                                    Text(trip.title)
                                        .lineLimit(1)
                                }
                                .font(.caption2.weight(.medium))
                                .foregroundColor(store.selectedTripFilter == trip.id ? Color.wandrAccent : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(store.selectedTripFilter == trip.id ? Color.wandrAccent.opacity(0.12) : Color.clear)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 4)
    }
}
