import SwiftUI

public struct MemoryCardView: View {
    public let memory: MemoryEntry
    public let onFavoriteToggle: () -> Void

    public init(memory: MemoryEntry, onFavoriteToggle: @escaping () -> Void) {
        self.memory = memory
        self.onFavoriteToggle = onFavoriteToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Location, Date & Favorite
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(Color.wandrAccent)
                        Text(memory.locationName)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Text(memory.title)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }

                Spacer()

                Button(action: onFavoriteToggle) {
                    Image(systemName: memory.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(memory.isFavorite ? .red : .secondary.opacity(0.6))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            // Primary Photo / Artwork if available
            if let photo = memory.primaryPhoto, photo.hasImage {
                WandrImageView(photo: photo, cornerRadius: 14)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            }

            // Diary story snippet
            if !memory.story.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(memory.previewSnippet)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }

            // Tags row
            if !memory.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(memory.tags, id: \.self) { tag in
                            TagPillView(text: tag, color: Color.wandrAccent)
                        }
                    }
                }
            }

            Divider()

            // Footer: Mood, Weather, Date, Star Rating
            HStack {
                HStack(spacing: 8) {
                    // Mood
                    Text(memory.mood.fullTitle)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(memory.mood.color.opacity(0.12))
                        .clipShape(Capsule())

                    // Weather
                    HStack(spacing: 3) {
                        Image(systemName: memory.weather.iconName)
                            .font(.caption2)
                        if let temp = memory.temperature, !temp.isEmpty {
                            Text(temp)
                                .font(.caption2.weight(.medium))
                        }
                    }
                    .foregroundColor(memory.weather.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(memory.weather.color.opacity(0.12))
                    .clipShape(Capsule())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    StarRatingView(rating: memory.rating, size: 12)

                    Text(memory.date.relativeOrFormatted)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .wandrCard()
    }
}
