import Foundation

public struct TravelStats {
    public let totalTrips: Int
    public let totalMemories: Int
    public let totalPhotos: Int
    public let totalTravelDays: Int
    public let visitedCountries: [String]
    public let favoriteCount: Int
    public let moodCounts: [(mood: TravelMood, count: Int)]
    public let categoryCounts: [(category: TripCategory, count: Int)]

    public init(trips: [Trip], memories: [MemoryEntry]) {
        self.totalTrips = trips.count
        self.totalMemories = memories.count

        // Total photos count
        let photoSum = memories.reduce(0) { $0 + $1.photos.count }
        self.totalPhotos = photoSum

        // Unique countries (case-insensitive deduplication)
        var countriesDict: [String: String] = [:]
        for trip in trips {
            let trimmed = trip.country.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                let key = trimmed.lowercased()
                if countriesDict[key] == nil {
                    countriesDict[key] = trimmed
                }
            }
        }
        for mem in memories {
            let trimmed = mem.country.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                let key = trimmed.lowercased()
                if countriesDict[key] == nil {
                    countriesDict[key] = trimmed
                }
            }
        }
        self.visitedCountries = Array(countriesDict.values).sorted()

        // Total travel days across trips
        self.totalTravelDays = trips.reduce(0) { $0 + $1.durationInDays }

        // Favorites
        let favMemories = memories.filter { $0.isFavorite }.count
        let favTrips = trips.filter { $0.isFavorite }.count
        self.favoriteCount = favMemories + favTrips

        // Mood counts
        var moodsDict: [TravelMood: Int] = [:]
        for mem in memories {
            moodsDict[mem.mood, default: 0] += 1
        }
        self.moodCounts = TravelMood.allCases.compactMap { mood in
            let count = moodsDict[mood] ?? 0
            return count > 0 ? (mood, count) : nil
        }.sorted { $0.count > $1.count }

        // Category counts
        var catDict: [TripCategory: Int] = [:]
        for trip in trips {
            catDict[trip.category, default: 0] += 1
        }
        self.categoryCounts = TripCategory.allCases.compactMap { cat in
            let count = catDict[cat] ?? 0
            return count > 0 ? (cat, count) : nil
        }.sorted { $0.count > $1.count }
    }
}
