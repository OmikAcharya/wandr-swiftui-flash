import Foundation
import SwiftUI

public struct Trip: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var destination: String
    public var country: String
    public var flagEmoji: String
    public var startDate: Date
    public var endDate: Date
    public var category: TripCategory
    public var notes: String
    public var coverImageName: String?
    public var customCoverImageData: Data?
    public var isFavorite: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        country: String,
        flagEmoji: String = "✈️",
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        category: TripCategory = .cultural,
        notes: String = "",
        coverImageName: String? = nil,
        customCoverImageData: Data? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.country = country
        self.flagEmoji = flagEmoji
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.notes = notes
        self.coverImageName = coverImageName
        self.customCoverImageData = customCoverImageData
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    public var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: calendar.startOfDay(for: endDate))
        return max(1, (components.day ?? 0) + 1)
    }

    public var status: TripStatus {
        let now = Date()
        let calendar = Calendar.current
        let startOfDayNow = calendar.startOfDay(for: now)
        let startOfTrip = calendar.startOfDay(for: startDate)
        let endOfTrip = calendar.startOfDay(for: endDate)

        if startOfDayNow < startOfTrip {
            return .upcoming
        } else if startOfDayNow > endOfTrip {
            return .completed
        } else {
            return .ongoing
        }
    }

    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }

    public var durationLabel: String {
        let days = durationInDays
        return days == 1 ? "1 day" : "\(days) days"
    }
}
