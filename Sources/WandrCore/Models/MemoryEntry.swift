import Foundation
import CoreLocation

public struct MemoryEntry: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var tripId: UUID?
    public var title: String
    public var story: String
    public var date: Date
    public var locationName: String
    public var country: String
    public var latitude: Double?
    public var longitude: Double?
    public var mood: TravelMood
    public var weather: WeatherCondition
    public var temperature: String?
    public var photos: [MemoryPhoto]
    public var tags: [String]
    public var rating: Int
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        tripId: UUID? = nil,
        title: String,
        story: String,
        date: Date = Date(),
        locationName: String,
        country: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        mood: TravelMood = .magical,
        weather: WeatherCondition = .sunny,
        temperature: String? = nil,
        photos: [MemoryPhoto] = [],
        tags: [String] = [],
        rating: Int = 5,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.tripId = tripId
        self.title = title
        self.story = story
        self.date = date
        self.locationName = locationName
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.mood = mood
        self.weather = weather
        self.temperature = temperature
        self.photos = photos
        self.tags = tags
        self.rating = max(1, min(5, rating))
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    public var primaryPhoto: MemoryPhoto? {
        photos.first(where: { $0.hasImage }) ?? photos.first
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var previewSnippet: String {
        let trimmed = story.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 160 {
            let index = trimmed.index(trimmed.startIndex, offsetBy: 160)
            return String(trimmed[..<index]) + "..."
        }
        return trimmed
    }
}
