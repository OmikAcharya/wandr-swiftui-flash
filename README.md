# ✈️ Wandr — Travel Diary & Memories App

**Wandr** is a travel diary mobile app crafted in **SwiftUI**. It allows you to document your journeys, write memories of the places you visit, add travel photos, explore past trips on an interactive world map, and share vintage souvenir postcards.

---

## 🌟 Key Features

### 1. 🧳 Trips & Journeys Management
- **Trip Lifecycle**: Track trips across `In Progress`, `Upcoming`, and `Completed` statuses.
- **Trip Metadata**: Destination, country, flag emojis, start & end dates, duration calculations, travel styles (`Adventure`, `Cultural`, `Road Trip`, `Relaxation`, `Nature`, `City`, `Foodie`), notes, and bucket lists.
- **Cover Artwork**: Upload custom photos or select stylized preset travel cover artwork (Kyoto, Amalfi Coast, Swiss Alps, New York, Paris, Bali, etc.).
- **Trip Timeline**: View dedicated journal moments and memories attached to each journey.

### 2. 📖 Travel Diary & Moments
- **Chronological Feed**: Browse all your travel memories in a stream with photo previews, weather, mood badges, and star ratings.
- **Rich Journaling**: Write comprehensive travel stories and narratives in an open notebook aesthetic.
- **Atmosphere Tracking**:
  - **Moods**: `✨ Magical`, `⚡ Adventurous`, `🌿 Peaceful`, `🤩 Amazed`, `☕ Cozy`, `🍜 Food Coma`, `😴 Exhausted`.
  - **Weather & Temp**: `☀️ Sunny`, `⛅ Partly Cloudy`, `☁️ Overcast`, `🌧️ Rainy`, `❄️ Snowy`, `💨 Breezy`, `🌫️ Misty` + temperature readings.
- **Tags & Highlights**: Tag moments with custom `#hashtags` (e.g. `#kyoto`, `#sunrise`, `#ramen`).
- **Instant Search & Filters**: Search across stories, locations, and tags, or filter by mood and journey.

### 3. 🗺️ Interactive World Travel Map
- Built with **MapKit** & SwiftUI.
- Displays custom pins for all memories with coordinates.
- Tap any pin to focus and view a summary card with location, thumbnail, title, and direct link to the journal entry.
- Filter map annotations by specific trip or view all global memories.

### 4. 📸 Travel Photos & Presets
- Native photo picker using Apple's `PhotosUI` (`PhotosPicker`).
- **Preset Travel Art Catalog**: Includes built-in procedural and vector gradient travel scenes so you can test the app immediately on simulators without needing real photos in your simulator camera roll!
- Photo captions and carousel viewer.

### 5. 💌 Souvenir Postcard Generator
- Transform any travel memory into a vintage airmail postcard complete with a stamp, postmark cancellation seal, destination tag, and journal excerpt.
- Shareable using native SwiftUI `ShareLink`.

### 6. 🛂 Travel Passport & Stats
- **Travel Passport Card**: Country count, days explored, total moments written, and photo count.
- **Countries Explored**: Country flag badge collection.
- **Mood Breakdown**: Visual frequency spectrum of how you felt while exploring.
- **Style Distribution**: Breakdown by trip category.
- **Settings**: Option to restore inspiring sample travels or clear data.

---

## 🏗️ Architecture & Project Structure

The project is structured cleanly using modern SwiftUI best practices:

```
IOSmini/
├── Package.swift                  # Swift Package Manager manifest (cross-platform macOS & iOS)
├── Wandr.xcodeproj/               # Native Xcode iOS Application project
│   └── project.pbxproj
├── Sources/
│   ├── WandrApp/                  # App Entry Point & Assets
│   │   ├── WandrApp.swift         # @main App declaration
│   │   ├── Info.plist             # iOS permissions & bundle settings
│   │   └── Assets.xcassets/       # AppIcon, AccentColor
│   ├── WandrCore/                 # Core Framework (Models, Services, Views)
│   │   ├── Models/
│   │   │   ├── Trip.swift
│   │   │   ├── TripCategory.swift
│   │   │   ├── MemoryEntry.swift
│   │   │   ├── MemoryPhoto.swift
│   │   │   ├── TravelMood.swift
│   │   │   ├── WeatherCondition.swift
│   │   │   └── TravelStats.swift
│   │   ├── Services/
│   │   │   ├── TravelStore.swift      # ObservableObject with JSON persistence
│   │   │   ├── PresetLocations.swift  # Built-in destinations & coordinates
│   │   │   └── SampleDataProvider.swift # Pre-loaded initial sample journeys
│   │   ├── Utilities/
│   │   │   ├── PlatformCompatibility.swift # Cross-platform UIImage / NSImage & Colors
│   │   │   ├── DateExtensions.swift
│   │   │   └── ViewModifiers.swift
│   │   └── Views/
│   │       ├── ContentView.swift      # Main 4-tab shell
│   │       ├── Trips/                 # TripsView, TripDetailView, TripCardView, AddEditTripView
│   │       ├── Timeline/              # TimelineFeedView, MemoryDetailView, MemoryCardView, AddEditMemoryView
│   │       ├── Map/                   # TravelMapView
│   │       ├── Stats/                 # TravelStatsView, PostcardShareView
│   │       └── Components/            # PhotoPickerSection, PresetArtworkView, StarRatingView, etc.
│   └── WandrSelfCheck/            # Automated verification test suite
│       └── main.swift
└── README.md
```

---

## 🚀 How to Compile & Run

### Method 1: In Xcode (iOS Simulator / iPhone)
1. Double-click or open `Wandr.xcodeproj` in Xcode:
   ```bash
   open Wandr.xcodeproj
   ```
2. In Xcode's toolbar, select any iOS Simulator (e.g. **iPhone 15 Pro**, **iPhone 16**, or iPad).
3. Press **Cmd + R** (or click the **Run** button).
4. The app will build and launch immediately!

### Method 2: From Terminal (Swift Package Manager / macOS)
You can also compile and run directly from the command line:

- **Run Automated Verification Checks**:
  ```bash
  swift run WandrSelfCheck
  ```

- **Launch the SwiftUI App**:
  ```bash
  swift run Wandr
  ```

---

## 💾 Local Persistence
- Travel data is automatically saved to JSON files (`wandr_trips.json`, `wandr_memories.json`) in the Application Documents directory using background thread-safe atomic writes.
- On first launch, Wandr automatically populates inspiring sample trips (Kyoto, Amalfi Coast, Swiss Alps) so the app looks vibrant immediately. You can add, edit, or delete any entry, and your changes will persist across app launches.
