import SwiftUI
import PhotosUI

public struct AddEditTripView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject public var store: TravelStore

    public let existingTrip: Trip?

    @State private var title: String = ""
    @State private var destination: String = ""
    @State private var country: String = ""
    @State private var flagEmoji: String = "✈️"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var category: TripCategory = .cultural
    @State private var notes: String = ""
    @State private var coverImageName: String? = "kyoto_temple"
    @State private var customCoverImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    public init(store: TravelStore, existingTrip: Trip? = nil) {
        self.store = store
        self.existingTrip = existingTrip
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section: Cover Image
                Section {
                    VStack(spacing: 12) {
                        WandrImageView(
                            presetName: coverImageName,
                            customData: customCoverImageData,
                            category: category,
                            cornerRadius: 14
                        )
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("Upload Photo", systemImage: "photo")
                                    .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.bordered)
                            .onChange(of: selectedPhotoItem) { item in
                                Task {
                                    if let data = try? await item?.loadTransferable(type: Data.self) {
                                        await MainActor.run {
                                            self.customCoverImageData = data
                                        }
                                    }
                                }
                            }

                            Menu {
                                ForEach(PresetLocations.all) { preset in
                                    Button("\(preset.flag) \(preset.name)") {
                                        self.coverImageName = preset.presetArt
                                        self.customCoverImageData = nil
                                    }
                                }
                            } label: {
                                Label("Preset Theme", systemImage: "sparkles")
                                    .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Trip Cover")
                }

                // Section: Quick Preset Picker
                Section("Quick Destination Suggestions") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PresetLocations.all) { preset in
                                Button {
                                    applyPreset(preset)
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(preset.flag)
                                        Text(preset.name)
                                            .font(.caption.weight(.medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(destination == preset.name ? Color.wandrAccent.opacity(0.2) : Color.primary.opacity(0.06))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                // Section: General Info
                Section("Trip Details") {
                    TextField("Trip Title (e.g. Summer in Tokyo)", text: $title)

                    HStack {
                        TextField("Flag Emoji", text: $flagEmoji)
                            .frame(width: 80)
                        TextField("Destination (e.g. Kyoto)", text: $destination)
                    }

                    TextField("Country (e.g. Japan)", text: $country)

                    Picker("Category", selection: $category) {
                        ForEach(TripCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                }

                // Section: Dates
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                // Section: Notes
                Section("Trip Notes & Bucket List") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 90)
                }
            }
            .navigationTitle(existingTrip == nil ? "New Trip" : "Edit Trip")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTrip()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let trip = existingTrip {
                    self.title = trip.title
                    self.destination = trip.destination
                    self.country = trip.country
                    self.flagEmoji = trip.flagEmoji
                    self.startDate = trip.startDate
                    self.endDate = trip.endDate
                    self.category = trip.category
                    self.notes = trip.notes
                    self.coverImageName = trip.coverImageName
                    self.customCoverImageData = trip.customCoverImageData
                }
            }
        }
    }

    private func applyPreset(_ preset: PresetLocation) {
        self.destination = preset.name
        self.country = preset.country
        self.flagEmoji = preset.flag
        self.coverImageName = preset.presetArt
        if title.isEmpty {
            self.title = "Journey to \(preset.name)"
        }
    }

    private func saveTrip() {
        if var trip = existingTrip {
            trip.title = title
            trip.destination = destination
            trip.country = country
            trip.flagEmoji = flagEmoji
            trip.startDate = startDate
            trip.endDate = endDate
            trip.category = category
            trip.notes = notes
            trip.coverImageName = coverImageName
            trip.customCoverImageData = customCoverImageData
            store.updateTrip(trip)
        } else {
            let newTrip = Trip(
                title: title,
                destination: destination,
                country: country,
                flagEmoji: flagEmoji,
                startDate: startDate,
                endDate: endDate,
                category: category,
                notes: notes,
                coverImageName: coverImageName,
                customCoverImageData: customCoverImageData
            )
            store.addTrip(newTrip)
        }
    }
}
