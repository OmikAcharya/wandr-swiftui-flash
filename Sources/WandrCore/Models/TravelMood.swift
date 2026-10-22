import SwiftUI

public enum TravelMood: String, Codable, CaseIterable, Identifiable {
    case magical = "Magical"
    case adventurous = "Adventurous"
    case peaceful = "Peaceful"
    case amazed = "Amazed"
    case cozy = "Cozy"
    case foodie = "Food Coma"
    case exhausted = "Exhausted"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .magical: return "✨"
        case .adventurous: return "⚡"
        case .peaceful: return "🌿"
        case .amazed: return "🤩"
        case .cozy: return "☕"
        case .foodie: return "🍜"
        case .exhausted: return "😴"
        }
    }

    public var symbol: String {
        switch self {
        case .magical: return "sparkles"
        case .adventurous: return "bolt.fill"
        case .peaceful: return "leaf.fill"
        case .amazed: return "star.fill"
        case .cozy: return "cup.and.saucer.fill"
        case .foodie: return "fork.knife"
        case .exhausted: return "moon.zzz.fill"
        }
    }

    public var color: Color {
        switch self {
        case .magical: return Color.purple
        case .adventurous: return Color.orange
        case .peaceful: return Color.green
        case .amazed: return Color.yellow
        case .cozy: return Color.brown
        case .foodie: return Color.red
        case .exhausted: return Color.indigo
        }
    }

    public var fullTitle: String {
        "\(emoji) \(rawValue)"
    }
}
