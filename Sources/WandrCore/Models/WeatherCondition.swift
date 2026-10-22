import SwiftUI

public enum WeatherCondition: String, Codable, CaseIterable, Identifiable {
    case sunny = "Sunny"
    case partlyCloudy = "Partly Cloudy"
    case cloudy = "Overcast"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case windy = "Breezy"
    case misty = "Misty / Foggy"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .partlyCloudy: return "⛅"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        case .windy: return "💨"
        case .misty: return "🌫️"
        }
    }

    public var iconName: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "snowflake"
        case .windy: return "wind"
        case .misty: return "cloud.fog.fill"
        }
    }

    public var color: Color {
        switch self {
        case .sunny: return .orange
        case .partlyCloudy: return .yellow
        case .cloudy: return .gray
        case .rainy: return .blue
        case .snowy: return .cyan
        case .windy: return .mint
        case .misty: return .secondary
        }
    }

    public var fullTitle: String {
        "\(emoji) \(rawValue)"
    }
}
