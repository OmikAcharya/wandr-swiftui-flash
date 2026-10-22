import SwiftUI

public struct PresetArtworkView: View {
    public let name: String?
    public let category: TripCategory?

    public init(name: String? = nil, category: TripCategory? = nil) {
        self.name = name
        self.category = category
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient

                // Foreground themed accents
                contentOverlay(size: geo.size)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }

    @ViewBuilder
    private var backgroundGradient: some View {
        switch name {
        case "kyoto_temple":
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.35, blue: 0.30), Color(red: 0.98, green: 0.65, blue: 0.40), Color(red: 0.40, green: 0.15, blue: 0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "amalfi_coast":
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.55, blue: 0.85), Color(red: 0.35, green: 0.75, blue: 0.85), Color(red: 0.95, green: 0.85, blue: 0.60)],
                startPoint: .top,
                endPoint: .bottom
            )
        case "swiss_alps":
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.35, blue: 0.55), Color(red: 0.60, green: 0.75, blue: 0.88), Color(red: 0.90, green: 0.94, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        case "paris_sunset":
            LinearGradient(
                colors: [Color(red: 0.45, green: 0.20, blue: 0.55), Color(red: 0.90, green: 0.40, blue: 0.50), Color(red: 0.98, green: 0.75, blue: 0.45)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        case "bali_tropical":
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.45, blue: 0.30), Color(red: 0.30, green: 0.70, blue: 0.50), Color(red: 0.95, green: 0.75, blue: 0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "nyc_skyline":
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.12, blue: 0.25), Color(red: 0.20, green: 0.25, blue: 0.45), Color(red: 0.85, green: 0.50, blue: 0.40)],
                startPoint: .top,
                endPoint: .bottom
            )
        case "santorini_island":
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.40, blue: 0.85), Color(red: 0.30, green: 0.65, blue: 0.95), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "iceland_aurora":
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.10, blue: 0.20), Color(red: 0.10, green: 0.55, blue: 0.45), Color(red: 0.30, green: 0.85, blue: 0.60)],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            if let cat = category {
                LinearGradient(
                    colors: [cat.accentColor.opacity(0.8), cat.accentColor.opacity(0.4), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color.orange.opacity(0.8), Color.purple.opacity(0.6), Color.blue.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    @ViewBuilder
    private func contentOverlay(size: CGSize) -> some View {
        ZStack {
            // Subtle glowing circle / sun
            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: size.height * 0.7, height: size.height * 0.7)
                .position(x: size.width * 0.75, y: size.height * 0.35)
                .blur(radius: 20)

            // Thematic icons & silhouettes
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: systemIconForPreset)
                        .font(.system(size: min(size.width, size.height) * 0.38, weight: .light))
                        .foregroundColor(Color.white.opacity(0.30))
                        .padding(.trailing, 16)
                        .padding(.bottom, 12)
                }
            }
        }
    }

    private var systemIconForPreset: String {
        switch name {
        case "kyoto_temple": return "torii.gate"
        case "amalfi_coast": return "sailboat.fill"
        case "swiss_alps": return "mountain.2.fill"
        case "paris_sunset": return "heart.fill"
        case "bali_tropical": return "leaf.fill"
        case "nyc_skyline": return "building.2.fill"
        case "santorini_island": return "sun.horizon.fill"
        case "iceland_aurora": return "sparkles"
        default:
            return category?.iconName ?? "airplane"
        }
    }
}

public struct WandrImageView: View {
    public let photo: MemoryPhoto?
    public let presetName: String?
    public let customData: Data?
    public let category: TripCategory?
    public let cornerRadius: CGFloat

    public init(
        photo: MemoryPhoto? = nil,
        presetName: String? = nil,
        customData: Data? = nil,
        category: TripCategory? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.photo = photo
        self.presetName = presetName ?? photo?.presetName
        self.customData = customData ?? photo?.imageData
        self.category = category
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Group {
            if let data = customData, let img = PlatformImage.from(data: data) {
                Image(platformImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                PresetArtworkView(name: presetName, category: category)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
