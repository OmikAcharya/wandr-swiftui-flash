import Foundation

public struct PresetLocation: Identifiable, Hashable {
    public var id: String { name }
    public let name: String
    public let country: String
    public let flag: String
    public let latitude: Double
    public let longitude: Double
    public let presetArt: String

    public init(name: String, country: String, flag: String, latitude: Double, longitude: Double, presetArt: String) {
        self.name = name
        self.country = country
        self.flag = flag
        self.latitude = latitude
        self.longitude = longitude
        self.presetArt = presetArt
    }
}

public enum PresetLocations {
    public static let all: [PresetLocation] = [
        PresetLocation(
            name: "Kyoto",
            country: "Japan",
            flag: "🇯🇵",
            latitude: 34.9671,
            longitude: 135.7727,
            presetArt: "kyoto_temple"
        ),
        PresetLocation(
            name: "Amalfi Coast",
            country: "Italy",
            flag: "🇮🇹",
            latitude: 40.6340,
            longitude: 14.6027,
            presetArt: "amalfi_coast"
        ),
        PresetLocation(
            name: "Swiss Alps",
            country: "Switzerland",
            flag: "🇨🇭",
            latitude: 45.9765,
            longitude: 7.7491,
            presetArt: "swiss_alps"
        ),
        PresetLocation(
            name: "Paris",
            country: "France",
            flag: "🇫🇷",
            latitude: 48.8584,
            longitude: 2.2945,
            presetArt: "paris_sunset"
        ),
        PresetLocation(
            name: "Bali",
            country: "Indonesia",
            flag: "🇮🇩",
            latitude: -8.3405,
            longitude: 115.0920,
            presetArt: "bali_tropical"
        ),
        PresetLocation(
            name: "New York City",
            country: "United States",
            flag: "🇺🇸",
            latitude: 40.7580,
            longitude: -73.9855,
            presetArt: "nyc_skyline"
        ),
        PresetLocation(
            name: "Santorini",
            country: "Greece",
            flag: "🇬🇷",
            latitude: 36.3932,
            longitude: 25.4615,
            presetArt: "santorini_island"
        ),
        PresetLocation(
            name: "Reykjavik",
            country: "Iceland",
            flag: "🇮🇸",
            latitude: 64.1466,
            longitude: -21.9426,
            presetArt: "iceland_aurora"
        )
    ]

    public static func match(locationName: String) -> PresetLocation? {
        let lower = locationName.lowercased()
        return all.first { preset in
            lower.contains(preset.name.lowercased()) ||
            lower.contains(preset.country.lowercased())
        }
    }
}
