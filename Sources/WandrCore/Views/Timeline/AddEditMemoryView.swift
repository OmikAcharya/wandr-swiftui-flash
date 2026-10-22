import SwiftUI
import CoreLocation

public struct AddEditMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var store: TravelStore

    public let existingMemory: MemoryEntry?
    public let preselectedTripId: UUID?

    @State private var title: String = ""
    @State private var story: String = ""
    @State private var date: Date = Date()
    @State private var locationName: String = ""
    @State private var country: String = ""
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    @State private var selectedTripId: UUID? = nil
    @State private var mood: TravelMood = .magical
    @State private var weather: WeatherCondition = .sunny
    @State private var temperature: String = ""
    @State private var rating: Int = 5
    @State private var tagsText: String = ""
    @State private var photos: [MemoryPhoto] = []
    @State private var hasLoadedInitialData: Bool = false

    public init(store: TravelStore, existingMemory: MemoryEntry? = nil, preselectedTripId: UUID? = nil) {
        self.store = store
        self.existingMemory = existingMemory
        self.preselectedTripId = preselectedTripId
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section: Header & Trip Association
                Section("Journal Entry") {
                    TextField("Moment Title (e.g. Sunrise at Temple)", text: $title)

                    Picker("Linked Trip", selection: $selectedTripId) {
                        Text("Standalone (No Trip)").tag(nil as UUID?)
                        ForEach(store.trips) { trip in
                            Text("\(trip.flagEmoji) \(trip.title)").tag(trip.id as UUID?)
                        }
                    }

                    DatePicker("Date & Time", selection: $date)
                }

                // Section: Location & Coordinates
                Section("Location & Map Pin") {
                    TextField("Place / Landmark (e.g. Positano Cliffside)", text: $locationName)
                    TextField("Country (e.g. Italy)", text: $country)

                    HStack {
                        TextField("Latitude", text: $latitudeString)
                            #if os(iOS)
                            .keyboardType(.numbersAndPunctuation)
                            #endif
                        TextField("Longitude", text: $longitudeString)
                            #if os(iOS)
                            .keyboardType(.numbersAndPunctuation)
                            #endif
                    }

                    // Suggestions for quick auto-fill
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quick Presets:")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(PresetLocations.all) { preset in
                                    Button {
                                        applyLocationPreset(preset)
                                    } label: {
                                        HStack(spacing: 3) {
                                            Text(preset.flag)
                                            Text(preset.name)
                                                .font(.caption2.weight(.semibold))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.primary.opacity(0.06))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Section: Mood, Weather & Rating
                Section("Atmosphere & Experience") {
                    Picker("Mood", selection: $mood) {
                        ForEach(TravelMood.allCases) { m in
                            Text(m.fullTitle).tag(m)
                        }
                    }

                    Picker("Weather", selection: $weather) {
                        ForEach(WeatherCondition.allCases) { w in
                            Text(w.fullTitle).tag(w)
                        }
                    }

                    TextField("Temperature (e.g. 21°C or 70°F)", text: $temperature)

                    HStack {
                        Text("Rating")
                        Spacer()
                        StarRatingView(rating: $rating, size: 22)
                    }
                }

                // Section: Photos
                Section {
                    PhotoPickerSection(photos: $photos)
                }

                // Section: Travel Story Narrative
                Section("Diary Story") {
                    TextEditor(text: $story)
                        .frame(minHeight: 140)
                }

                // Section: Tags
                Section("Tags") {
                    TextField("Tags (comma or space separated, e.g. #kyoto, #sunset)", text: $tagsText)
                }
            }
            .navigationTitle(existingMemory == nil ? "New Memory" : "Edit Memory")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMemory()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || locationName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard !hasLoadedInitialData else { return }
                hasLoadedInitialData = true
                if let memory = existingMemory {
                    self.title = memory.title
                    self.story = memory.story
                    self.date = memory.date
                    self.locationName = memory.locationName
                    self.country = memory.country
                    if let lat = memory.latitude { self.latitudeString = String(lat) }
                    if let lon = memory.longitude { self.longitudeString = String(lon) }
                    self.selectedTripId = memory.tripId
                    self.mood = memory.mood
                    self.weather = memory.weather
                    self.temperature = memory.temperature ?? ""
                    self.rating = memory.rating
                    self.tagsText = memory.tags.joined(separator: ", ")
                    self.photos = memory.photos
                } else if let preId = preselectedTripId {
                    self.selectedTripId = preId
                    if let trip = store.trip(for: preId) {
                        self.country = trip.country
                        self.locationName = trip.destination
                        if let preset = PresetLocations.match(locationName: trip.destination) {
                            applyLocationPreset(preset)
                        }
                    }
                }
            }
        }
    }

    private func applyLocationPreset(_ preset: PresetLocation) {
        self.locationName = "\(preset.name)"
        self.country = preset.country
        self.latitudeString = String(preset.latitude)
        self.longitudeString = String(preset.longitude)
        if photos.isEmpty {
            photos.append(MemoryPhoto(presetName: preset.presetArt, caption: "\(preset.flag) \(preset.name)"))
        }
    }

    private func saveMemory() {
        let lat = Double(latitudeString.trimmingCharacters(in: .whitespaces))
        let lon = Double(longitudeString.trimmingCharacters(in: .whitespaces))

        let parsedTags = tagsText
            .components(separatedBy: CharacterSet(charactersIn: ", "))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != "#" }
            .map { $0.hasPrefix("#") ? $0 : "#\($0)" }

        if var memory = existingMemory {
            memory.title = title
            memory.story = story
            memory.date = date
            memory.locationName = locationName
            memory.country = country
            memory.latitude = lat
            memory.longitude = lon
            memory.tripId = selectedTripId
            memory.mood = mood
            memory.weather = weather
            memory.temperature = temperature.isEmpty ? nil : temperature
            memory.rating = rating
            memory.tags = parsedTags
            memory.photos = photos
            store.updateMemory(memory)
        } else {
            let newMemory = MemoryEntry(
                tripId: selectedTripId,
                title: title,
                story: story,
                date: date,
                locationName: locationName,
                country: country,
                latitude: lat,
                longitude: lon,
                mood: mood,
                weather: weather,
                temperature: temperature.isEmpty ? nil : temperature,
                photos: photos,
                tags: parsedTags,
                rating: rating
            )
            store.addMemory(newMemory)
        }
    }
}
