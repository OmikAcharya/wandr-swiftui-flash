import SwiftUI

public enum TripCategory: String, Codable, CaseIterable, Identifiable {
    case adventure = "Adventure"
    case cultural = "Cultural"
    case roadtrip = "Road Trip"
    case relaxation = "Relaxation"
    case nature = "Nature & Parks"
    case urban = "City & Urban"
    case foodie = "Food & Drink"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .adventure: return "figure.hiking"
        case .cultural: return "building.columns.fill"
        case .roadtrip: return "car.fill"
        case .relaxation: return "beach.umbrella.fill"
        case .nature: return "leaf.fill"
        case .urban: return "tram.fill"
        case .foodie: return "fork.knife"
        }
    }

    public var accentColor: Color {
        switch self {
        case .adventure: return Color.orange
        case .cultural: return Color.purple
        case .roadtrip: return Color.blue
        case .relaxation: return Color.teal
        case .nature: return Color.green
        case .urban: return Color.indigo
        case .foodie: return Color.red
        }
    }
}

public enum TripStatus: String, Codable {
    case upcoming = "Upcoming"
    case ongoing = "In Progress"
    case completed = "Completed"

    public var badgeColor: Color {
        switch self {
        case .upcoming: return Color.blue
        case .ongoing: return Color.green
        case .completed: return Color.secondary
        }
    }

    public var iconName: String {
        switch self {
        case .upcoming: return "calendar.badge.clock"
        case .ongoing: return "airplane.departure"
        case .completed: return "checkmark.seal.fill"
        }
    }
}
