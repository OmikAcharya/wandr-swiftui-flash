import Foundation
import WandrCore
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

func runAllChecks() {
    print("🚀 Starting Wandr automated self-checks...")

    // 1. Check Trip duration, single-day bounds and status calculation
    let calendar = Calendar.current
    let today = Date()

    let singleDay = Trip(
        title: "Day Hike",
        destination: "Nara Park",
        country: "Japan",
        startDate: today,
        endDate: today
    )
    assert(singleDay.durationInDays == 1, "Expected 1 day duration for same-day trip")
    assert(singleDay.durationLabel == "1 day", "Expected '1 day' duration label")

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

    // 2. Check MemoryEntry calculations & bounds
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
        rating: 10 // Should clamp to 5
    )
    assert(memory.rating == 5, "Rating should be clamped to 5")
    assert(memory.coordinate != nil, "Expected valid coordinates")
    assert(memory.coordinate?.latitude == 34.9671, "Expected latitude 34.9671")
    assert(memory.coordinate?.longitude == 135.7727, "Expected longitude 135.7727")
    assert(memory.previewSnippet.hasSuffix("..."), "Expected truncated snippet")
    assert(memory.previewSnippet.count <= 165, "Snippet should be <= 165 chars")

    let lowRatingMem = MemoryEntry(
        title: "Rainy Day",
        story: "Stuck inside",
        locationName: "London",
        rating: -1 // Should clamp to 1
    )
    assert(lowRatingMem.rating == 1, "Rating should clamp to minimum 1")
    assert(lowRatingMem.coordinate == nil, "Coordinate should be nil when lat/lon omitted")
    print("  ✓ MemoryEntry coordinate, snippet & boundary clamping logic verified")

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

    // 4. Check TravelStats & Case-Insensitive Country Deduplication
    let stats = store.stats
    assert(stats.totalTrips == 4, "Stats total trips should be 4")
    assert(stats.totalMemories == 5, "Stats total memories should be 5")
    assert(stats.totalPhotos == 5, "Stats total photos should be 5")
    assert(stats.visitedCountries.contains("Japan"), "Visited countries should contain Japan")
    assert(stats.visitedCountries.contains("Italy"), "Visited countries should contain Italy")
    assert(stats.visitedCountries.contains("Switzerland"), "Visited countries should contain Switzerland")

    let customStats = TravelStats(
        trips: [
            Trip(title: "Trip A", destination: "Tokyo", country: "Japan"),
            Trip(title: "Trip B", destination: "Kyoto", country: "japan")
        ],
        memories: [
            MemoryEntry(title: "Mem 1", story: "", locationName: "Rome", country: "Italy"),
            MemoryEntry(title: "Mem 2", story: "", locationName: "Venice", country: "ITALY")
        ]
    )
    assert(customStats.visitedCountries.count == 2, "Country deduplication should combine case variations into 2 countries")
    print("  ✓ TravelStats summary & country deduplication verified")

    // 5. Check Image Downsampling helper
    #if canImport(AppKit)
    let size = NSSize(width: 200, height: 200)
    let testImg = NSImage(size: size)
    testImg.lockFocus()
    NSColor.orange.setFill()
    NSRect(origin: .zero, size: size).fill()
    testImg.unlockFocus()
    if let data = testImg.toJpegData(compressionQuality: 0.9) {
        let downsampled = PlatformImage.downsample(data: data, maxPixelDimension: 80, compressionQuality: 0.7)
        assert(downsampled != nil, "Downsampling should succeed")
        assert((downsampled?.count ?? 0) > 0, "Downsampled data should not be empty")
        if let ds = downsampled, let dsImg = NSImage(data: ds) {
            assert(dsImg.size.width <= 80, "Downsampled image width should be <= 80")
        }
    }
    #elseif canImport(UIKit)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
    let testImg = renderer.image { ctx in
        UIColor.orange.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
    }
    if let data = testImg.jpegData(compressionQuality: 0.9) {
        let downsampled = PlatformImage.downsample(data: data, maxPixelDimension: 80, compressionQuality: 0.7)
        assert(downsampled != nil, "Downsampling should succeed")
        assert((downsampled?.count ?? 0) > 0, "Downsampled data should not be empty")
        if let ds = downsampled, let dsImg = UIImage(data: ds) {
            assert(dsImg.size.width <= 80, "Downsampled image width should be <= 80")
        }
    }
    #endif
    print("  ✓ Image downsampling pipeline verified")

    // 6. Check Persistence User Empty State Preservation
    store.clearAllData()
    // Give async file write time to complete
    Thread.sleep(forTimeInterval: 0.1)

    // Simulate relaunching the app with loadSamplesIfEmpty: true
    let restartedStore = TravelStore(loadSamplesIfEmpty: true)
    assert(restartedStore.trips.isEmpty, "User's empty trips state must be preserved across app relaunch")
    assert(restartedStore.memories.isEmpty, "User's empty memories state must be preserved across app relaunch")

    // Restore samples for subsequent normal use
    restartedStore.resetToSampleData()
    assert(restartedStore.trips.count == 4, "resetToSampleData should restore sample trips")
    print("  ✓ Persistence user empty state preservation verified")

    print("🎉 All 6 verification test suites passed successfully with 0 errors!")
}

runAllChecks()
