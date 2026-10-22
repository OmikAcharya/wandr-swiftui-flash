import SwiftUI

public struct PostcardShareView: View {
    @Environment(\.dismiss) private var dismiss
    public let memory: MemoryEntry

    public init(memory: MemoryEntry) {
        self.memory = memory
    }

    private var shareText: String {
        """
        ✈️ Souvenir Postcard from \(memory.locationName) (\(memory.country))
        "\(memory.title)"
        \(memory.previewSnippet)
        Logged with Wandr Travel Diary
        """
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Vintage Postcard
                    postcardCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // Share button
                    ShareLink(item: shareText) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Souvenir Postcard")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.wandrAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.wandrAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Souvenir Postcard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var postcardCard: some View {
        VStack(spacing: 12) {
            // Airmail border effect
            ZStack(alignment: .topTrailing) {
                // Postcard photo
                if let photo = memory.primaryPhoto, photo.hasImage {
                    WandrImageView(photo: photo, cornerRadius: 10)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                } else {
                    PresetArtworkView(name: "paris_sunset")
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                // Postage Stamp
                VStack(spacing: 2) {
                    Image(systemName: "airplane")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Text("AIR MAIL")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.red)
                    Text(memory.date.shortMonthDay)
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                }
                .padding(6)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .stroke(Color.red.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                )
                .rotationEffect(.degrees(8))
                .padding(12)
            }

            // Postcard Body (divided like real postcard)
            HStack(alignment: .top, spacing: 16) {
                // Left: Handwritten Message
                VStack(alignment: .leading, spacing: 8) {
                    Text(memory.title)
                        .font(.system(.subheadline, design: .serif, weight: .bold))
                        .foregroundColor(.primary)

                    Text(memory.previewSnippet)
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)

                    Spacer(minLength: 8)

                    Text("~ \(memory.formattedDate)")
                        .font(.system(size: 10, design: .serif))
                        .italic()
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Vertical Divider
                Rectangle()
                    .fill(Color.primary.opacity(0.12))
                    .frame(width: 1)

                // Right: Address lines & location stamp
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color.wandrAccent)
                        Text(memory.country.isEmpty ? "Destination" : memory.country)
                            .font(.caption.weight(.bold))
                    }

                    Text(memory.locationName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Spacer()

                    Text(memory.mood.fullTitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(memory.mood.color)

                    // Postmark circular stamp
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                            .frame(width: 44, height: 44)
                        Text("PASSPORT\nCHECKED")
                            .font(.system(size: 6, weight: .heavy))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.blue.opacity(0.7))
                    }
                    .rotationEffect(.degrees(-12))
                }
                .frame(width: 110, alignment: .leading)
            }
            .padding(14)
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.94)) // Vintage off-white parchment paper
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}
