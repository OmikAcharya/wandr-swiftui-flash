import Foundation
import SwiftUI
import Combine

public final class TravelStore: ObservableObject {
    @Published public var trips: [Trip] = []
    @Published public var memories: [MemoryEntry] = []
    @Published public var selectedTab: Int = 0
    @Published public var searchText: String = ""
    @Published public var selectedTripFilter: UUID? = nil
    @Published public var selectedMoodFilter: TravelMood? = nil

    private let tripsFileName = "wandr_trips.json"
    private let memoriesFileName = "wandr_memories.json"
    private let fileQueue = DispatchQueue(label: "com.wandr.storage", qos: .background)

    public init(loadSamplesIfEmpty: Bool = true) {
        loadData(loadSamplesIfEmpty: loadSamplesIfEmpty)
    }

    // MARK: - File URLs
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var tripsFileURL: URL {
        documentsDirectory.appendingPathComponent(tripsFileName)
    }

    private var memoriesFileURL: URL {
        documentsDirectory.appendingPathComponent(memoriesFileName)
    }

    // MARK: - Persistence
    public func loadData(loadSamplesIfEmpty: Bool = true) {
        var loadedTrips: [Trip]? = nil
        var loadedMemories: [MemoryEntry]? = nil

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let tripsExist = FileManager.default.fileExists(atPath: tripsFileURL.path)
        let memoriesExist = FileManager.default.fileExists(atPath: memoriesFileURL.path)

        if tripsExist, let data = try? Data(contentsOf: tripsFileURL) {
            loadedTrips = try? decoder.decode([Trip].self, from: data)
        }

        if memoriesExist, let data = try? Data(contentsOf: memoriesFileURL) {
            loadedMemories = try? decoder.decode([MemoryEntry].self, from: data)
        }

        if tripsExist || memoriesExist {
            // Data files already exist on disk; respect user's data (even if empty)
            self.trips = loadedTrips ?? []
            self.memories = loadedMemories ?? []
        } else if loadSamplesIfEmpty {
            // Fresh install: populate sample journeys
            let samples = SampleDataProvider.makeSampleData()
            self.trips = samples.trips
            self.memories = samples.memories
            saveData()
        }
    }

    public func saveData() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let currentTrips = self.trips
        let currentMemories = self.memories
        let tripsUrl = self.tripsFileURL
        let memoriesUrl = self.memoriesFileURL

        fileQueue.async {
            do {
                let tripsData = try encoder.encode(currentTrips)
                try tripsData.write(to: tripsUrl, options: [.atomicWrite])

                let memData = try encoder.encode(currentMemories)
                try memData.write(to: memoriesUrl, options: [.atomicWrite])
            } catch {
                print("Failed to save Wandr data: \(error)")
            }
        }
    }

    // MARK: - Trips CRUD
    public func addTrip(_ trip: Trip) {
        trips.insert(trip, at: 0)
        saveData()
    }

    public func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveData()
        }
    }

    public func deleteTrip(_ trip: Trip) {
        trips.removeAll(where: { $0.id == trip.id })
        // Clean up linked memories or unlink them
        for i in 0..<memories.count {
            if memories[i].tripId == trip.id {
                memories[i].tripId = nil
            }
        }
        saveData()
    }

    public func toggleFavoriteTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].isFavorite.toggle()
            saveData()
        }
    }

    // MARK: - Memories CRUD
    public func addMemory(_ memory: MemoryEntry) {
        memories.insert(memory, at: 0)
        saveData()
    }

    public func updateMemory(_ memory: MemoryEntry) {
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            var updated = memory
            updated.updatedAt = Date()
            memories[index] = updated
            saveData()
        }
    }

    public func deleteMemory(_ memory: MemoryEntry) {
        memories.removeAll(where: { $0.id == memory.id })
        saveData()
    }

    public func toggleFavoriteMemory(_ memory: MemoryEntry) {
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            memories[index].isFavorite.toggle()
            saveData()
        }
    }

    // MARK: - Queries & Filtering
    public func trip(for id: UUID?) -> Trip? {
        guard let id = id else { return nil }
        return trips.first(where: { $0.id == id })
    }

    public func memories(for trip: Trip) -> [MemoryEntry] {
        memories
            .filter { $0.tripId == trip.id }
            .sorted { $0.date > $1.date }
    }

    public func filteredMemories() -> [MemoryEntry] {
        var result = memories

        if let tripId = selectedTripFilter {
            result = result.filter { $0.tripId == tripId }
        }

        if let mood = selectedMoodFilter {
            result = result.filter { $0.mood == mood }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { entry in
                entry.title.lowercased().contains(query) ||
                entry.story.lowercased().contains(query) ||
                entry.locationName.lowercased().contains(query) ||
                entry.country.lowercased().contains(query) ||
                entry.tags.contains(where: { $0.lowercased().contains(query) })
            }
        }

        return result.sorted { $0.date > $1.date }
    }

    public var stats: TravelStats {
        TravelStats(trips: trips, memories: memories)
    }

    public func resetToSampleData() {
        let samples = SampleDataProvider.makeSampleData()
        self.trips = samples.trips
        self.memories = samples.memories
        self.selectedTripFilter = nil
        self.selectedMoodFilter = nil
        self.searchText = ""
        saveData()
    }

    public func clearAllData() {
        self.trips = []
        self.memories = []
        self.selectedTripFilter = nil
        self.selectedMoodFilter = nil
        self.searchText = ""
        saveData()
    }
}
