import SwiftUI

public struct TripCardView: View {
    public let trip: Trip
    public let memoryCount: Int
    public let onFavoriteToggle: () -> Void

    public init(trip: Trip, memoryCount: Int, onFavoriteToggle: @escaping () -> Void) {
        self.trip = trip
        self.memoryCount = memoryCount
        self.onFavoriteToggle = onFavoriteToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Image
            ZStack(alignment: .topTrailing) {
                WandrImageView(
                    presetName: trip.coverImageName,
                    customData: trip.customCoverImageData,
                    category: trip.category,
                    cornerRadius: 0
                )
                .frame(height: 150)
                .frame(maxWidth: .infinity)

                // Top badges
                HStack {
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: trip.status.iconName)
                            .font(.system(size: 11, weight: .bold))
                        Text(trip.status.rawValue)
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                    Spacer()

                    // Favorite Button
                    Button(action: onFavoriteToggle) {
                        Image(systemName: trip.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(trip.isFavorite ? .red : .white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
            }

            // Info Section
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(trip.flagEmoji)
                                .font(.headline)
                            Text(trip.destination)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                        }

                        Text(trip.title)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Category Pill
                    HStack(spacing: 4) {
                        Image(systemName: trip.category.iconName)
                        Text(trip.category.rawValue)
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(trip.category.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(trip.category.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                }

                Divider()

                // Footer metadata
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(trip.formattedDateRange)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        // Days count
                        Text(trip.durationLabel)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary.opacity(0.5))

                        // Memories count
                        HStack(spacing: 3) {
                            Image(systemName: "book.pages")
                            Text("\(memoryCount)")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color.wandrAccent)
                    }
                }
            }
            .padding(14)
        }
        .background(Color.wandrCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}
