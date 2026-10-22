import SwiftUI

public struct TravelStatsView: View {
    @ObservedObject public var store: TravelStore

    @State private var showResetAlert: Bool = false
    @State private var showClearAlert: Bool = false

    public init(store: TravelStore) {
        self.store = store
    }

    private var stats: TravelStats {
        store.stats
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Passport Header Card
                    passportHeaderCard

                    // 4-Quadrant Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        statCard(
                            icon: "airplane.circle.fill",
                            value: "\(stats.totalTrips)",
                            label: "Journeys",
                            color: .orange
                        )

                        statCard(
                            icon: "book.pages.fill",
                            value: "\(stats.totalMemories)",
                            label: "Moments Written",
                            color: .blue
                        )

                        statCard(
                            icon: "calendar.badge.clock",
                            value: "\(stats.totalTravelDays)",
                            label: "Days Explored",
                            color: .teal
                        )

                        statCard(
                            icon: "photo.stack.fill",
                            value: "\(stats.totalPhotos)",
                            label: "Photos Saved",
                            color: .purple
                        )
                    }
                    .padding(.horizontal, 16)

                    // Countries Visited
                    if !stats.visitedCountries.isEmpty {
                        countriesVisitedSection
                    }

                    // Mood Breakdown
                    if !stats.moodCounts.isEmpty {
                        moodBreakdownSection
                    }

                    // Category Breakdown
                    if !stats.categoryCounts.isEmpty {
                        categoryBreakdownSection
                    }

                    // Data Management & Settings
                    dataManagementSection
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Travel Passport")
            .alert("Restore Sample Travels?", isPresented: $showResetAlert) {
                Button("Restore", role: .destructive) {
                    store.resetToSampleData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will replace current entries with inspiring sample journeys to Kyoto, Amalfi, and the Swiss Alps.")
            }
            .alert("Clear All Travels?", isPresented: $showClearAlert) {
                Button("Clear All", role: .destructive) {
                    store.clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your trips and memories. This action cannot be undone.")
            }
        }
    }

    // MARK: - Passport Header
    private var passportHeaderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("TRAVEL PASSPORT", systemImage: "globe.americas.fill")
                    .font(.caption.weight(.heavy))
                    .foregroundColor(Color.wandrAccent)

                Spacer()

                Text("WANDR")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("World Wanderer")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                Text("\(stats.visitedCountries.count) countries visited • \(stats.totalTravelDays) days on the road")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(stats.visitedCountries.prefix(6), id: \.self) { country in
                    let preset = PresetLocations.all.first(where: { $0.country.lowercased() == country.lowercased() })
                    Text(preset?.flag ?? "🌍")
                        .font(.title3)
                        .padding(6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.wandrCardBackground, Color.wandrAccent.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.wandrAccent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 16)
    }

    // MARK: - Stat Card
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.wandrCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Countries Visited
    private var countriesVisitedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Countries Explored")
                .font(.headline)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(stats.visitedCountries, id: \.self) { country in
                        let preset = PresetLocations.all.first(where: { $0.country.lowercased() == country.lowercased() })
                        HStack(spacing: 6) {
                            Text(preset?.flag ?? "📍")
                            Text(country)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.wandrCardBackground)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Mood Breakdown
    private var moodBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Travel Feelings & Moods")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 10) {
                ForEach(stats.moodCounts, id: \.mood) { item in
                    HStack {
                        HStack(spacing: 6) {
                            Text(item.mood.emoji)
                            Text(item.mood.rawValue)
                                .font(.subheadline.weight(.medium))
                        }

                        Spacer()

                        Text("\(item.count) moments")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)

                        // Relative bar
                        let maxCount = stats.moodCounts.first?.count ?? 1
                        let ratio = CGFloat(item.count) / CGFloat(max(1, maxCount))

                        GeometryReader { geo in
                            Capsule()
                                .fill(item.mood.color)
                                .frame(width: geo.size.width * ratio, height: 8)
                        }
                        .frame(width: 70, height: 8)
                    }
                }
            }
            .padding(16)
            .background(Color.wandrCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Category Breakdown
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip Styles")
                .font(.headline)
                .padding(.horizontal, 16)

            HStack(spacing: 8) {
                ForEach(stats.categoryCounts, id: \.category) { item in
                    VStack(spacing: 6) {
                        Image(systemName: item.category.iconName)
                            .font(.headline)
                            .foregroundColor(item.category.accentColor)

                        Text("\(item.count)")
                            .font(.headline.weight(.bold))

                        Text(item.category.rawValue)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.wandrCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Data Management
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Journal Settings")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                Button {
                    showResetAlert = true
                } label: {
                    HStack {
                        Label("Load Sample Travels", systemImage: "sparkles")
                            .foregroundColor(Color.wandrAccent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    showClearAlert = true
                } label: {
                    HStack {
                        Label("Clear All Travels", systemImage: "trash")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                }
                .buttonStyle(.plain)
            }
            .background(Color.wandrCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 16)
        }
    }
}
