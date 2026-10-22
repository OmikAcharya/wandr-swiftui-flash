import Foundation
import WandrCore

func runAllChecks() {
    print("🚀 Starting Wandr automated self-checks...")

    // 1. Check Trip duration and status calculation
    let calendar = Calendar.current
    let today = Date()

    let upcomingStart = calendar.date(byAdding: .day, value: 5, to: today)!
    let upcomingEnd = calendar.date(byAdding: .day, value: 12, to: today)!
    let upcomingTrip = Trip(
        title: "Future Adventure",
        destination: "Reykjavik",
        country: "Iceland",
        startDate: upcomingStart,
        endDate: upcomingEnd
    )
    assert(upcomingTrip.durationInDays == 8, "Expected 8 days duration")
    assert(upcomingTrip.status == .upcoming, "Expected status to be upcoming")
    print("  ✓ Trip duration & status logic verified")

    // Past trip
    let pastStart = calendar.date(byAdding: .day, value: -20, to: today)!
    let pastEnd = calendar.date(byAdding: .day, value: -10, to: today)!
    let pastTrip = Trip(
        title: "Past Adventure",
        destination: "Rome",
        country: "Italy",
        startDate: pastStart,
        endDate: pastEnd
    )
    assert(pastTrip.status == .completed, "Expected status to be completed")
    print("  ✓ Completed trip status logic verified")

    // 2. Check MemoryEntry calculations
    let longStory = String(repeating: "Wandr travel memory story. ", count: 20)
    let memory = MemoryEntry(
        title: "Sunrise Walk",
        story: longStory,
        locationName: "Fushimi Inari",
        country: "Japan",
        latitude: 34.9671,
        longitude: 135.7727,
        mood: .magical,
        weather: .sunny,
        rating: 5
    )
    assert(memory.coordinate != nil, "Expected valid coordinates")
    assert(memory.coordinate?.latitude == 34.9671, "Expected latitude 34.9671")
    assert(memory.coordinate?.longitude == 135.7727, "Expected longitude 135.7727")
    assert(memory.previewSnippet.hasSuffix("..."), "Expected truncated snippet")
    assert(memory.previewSnippet.count <= 165, "Snippet should be <= 165 chars")
    print("  ✓ MemoryEntry coordinate & snippet logic verified")

    // 3. Check TravelStore CRUD, search and filtering
    let store = TravelStore(loadSamplesIfEmpty: false)
    store.clearAllData()

    assert(store.trips.isEmpty, "Store should have 0 trips")
    assert(store.memories.isEmpty, "Store should have 0 memories")

    let trip = Trip(
        title: "Kyoto Expedition",
        destination: "Kyoto",
        country: "Japan"
    )
    store.addTrip(trip)
    assert(store.trips.count == 1, "Expected 1 trip")

    let entry = MemoryEntry(
        tripId: trip.id,
        title: "Golden Pavilion",
        story: "Astonishing gold leaf reflecting on the pond",
        locationName: "Kinkaku-ji",
        country: "Japan",
        mood: .amazed,
        tags: ["#gold", "#kyoto"]
    )
    store.addMemory(entry)
    assert(store.memories.count == 1, "Expected 1 memory")

    let tripMems = store.memories(for: trip)
    assert(tripMems.count == 1, "Expected 1 memory for trip")
    assert(tripMems.first?.title == "Golden Pavilion", "Expected title match")

    // Search query
    store.searchText = "astonishing"
    assert(store.filteredMemories().count == 1, "Search should match story text")

    store.searchText = "nonexistent_query_xyz"
    assert(store.filteredMemories().count == 0, "Non-existent search should return empty")

    store.searchText = ""

    // Mood filter
    store.selectedMoodFilter = .amazed
    assert(store.filteredMemories().count == 1, "Mood filter should match")

    store.selectedMoodFilter = .exhausted
    assert(store.filteredMemories().count == 0, "Different mood should not match")
    store.selectedMoodFilter = nil

    // Favorite toggle
    store.toggleFavoriteMemory(entry)
    assert(store.memories.first?.isFavorite == true, "Memory favorite should be toggled")

    // Deleting trip unlinks memory
    store.deleteTrip(trip)
    assert(store.trips.isEmpty, "Trips should be empty")
    assert(store.memories.count == 1, "Memory should still exist")
    assert(store.memories.first?.tripId == nil, "Memory should now be unlinked")

    // Reset to samples
    store.resetToSampleData()
    assert(store.trips.count == 4, "Sample data should have 4 trips")
    assert(store.memories.count == 5, "Sample data should have 5 memories")
    print("  ✓ TravelStore CRUD, search & filtering logic verified")

    // 4. Check TravelStats
    let stats = store.stats
    assert(stats.totalTrips == 4, "Stats total trips should be 4")
    assert(stats.totalMemories == 5, "Stats total memories should be 5")
    assert(stats.totalPhotos == 5, "Stats total photos should be 5")
    assert(stats.visitedCountries.contains("Japan"), "Visited countries should contain Japan")
    assert(stats.visitedCountries.contains("Italy"), "Visited countries should contain Italy")
    assert(stats.visitedCountries.contains("Switzerland"), "Visited countries should contain Switzerland")
    print("  ✓ TravelStats summary aggregation verified")

    print("🎉 All 4 verification test suites passed successfully with 0 errors!")
}

runAllChecks()
