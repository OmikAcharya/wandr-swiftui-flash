import Foundation

public enum SampleDataProvider {
    public static func makeSampleData() -> (trips: [Trip], memories: [MemoryEntry]) {
        let calendar = Calendar.current
        let now = Date()

        // Trips
        let kyotoTrip = Trip(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            title: "Ancient Temples & Bamboo Groves",
            destination: "Kyoto & Nara",
            country: "Japan",
            flagEmoji: "🇯🇵",
            startDate: calendar.date(byAdding: .day, value: -14, to: now)!,
            endDate: calendar.date(byAdding: .day, value: -6, to: now)!,
            category: .cultural,
            notes: "Must see: Fushimi Inari at dawn, Arashiyama bamboo forest, Nishiki Market street food.",
            coverImageName: "kyoto_temple",
            isFavorite: true
        )

        let amalfiTrip = Trip(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            title: "Sun-Drenched Amalfi & Capri",
            destination: "Positano & Capri",
            country: "Italy",
            flagEmoji: "🇮🇹",
            startDate: calendar.date(byAdding: .day, value: -45, to: now)!,
            endDate: calendar.date(byAdding: .day, value: -38, to: now)!,
            category: .relaxation,
            notes: "Rent a boat to Faraglioni rocks, hike Path of the Gods, taste authentic lemon granita.",
            coverImageName: "amalfi_coast",
            isFavorite: true
        )

        let swissTrip = Trip(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            title: "Alpine Trekking & The Matterhorn",
            destination: "Zermatt & Gornergrat",
            country: "Switzerland",
            flagEmoji: "🇨🇭",
            startDate: calendar.date(byAdding: .day, value: -90, to: now)!,
            endDate: calendar.date(byAdding: .day, value: -84, to: now)!,
            category: .adventure,
            notes: "High elevation trail. Remember hiking poles, mountain boots, and emergency glacier poncho.",
            coverImageName: "swiss_alps",
            isFavorite: false
        )

        let nycTrip = Trip(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            title: "Autumn Foliage & Broadway Nights",
            destination: "New York City",
            country: "United States",
            flagEmoji: "🇺🇸",
            startDate: calendar.date(byAdding: .day, value: 10, to: now)!,
            endDate: calendar.date(byAdding: .day, value: 17, to: now)!,
            category: .urban,
            notes: "Upcoming trip! Central Park autumn walks, High Line sunset, jazz club in Greenwich Village.",
            coverImageName: "nyc_skyline",
            isFavorite: false
        )

        let trips = [kyotoTrip, amalfiTrip, swissTrip, nycTrip]

        // Memories
        let memories: [MemoryEntry] = [
            MemoryEntry(
                id: UUID(uuidString: "aaaa1111-0000-0000-0000-000000000001")!,
                tripId: kyotoTrip.id,
                title: "First Light at Fushimi Inari",
                story: "Woke up at 5:30 AM to beat the crowds at Fushimi Inari. Walking up through the thousands of vermilion torii gates in the quiet morning mist was completely surreal. The smell of cedar, the soft mountain breeze, and the morning sunbeams filtering through the branches made it feel like stepping into another world. Stopped at a small tea house halfway up for fresh matcha.",
                date: calendar.date(byAdding: .day, value: -13, to: now)!,
                locationName: "Fushimi Inari Taisha, Kyoto",
                country: "Japan",
                latitude: 34.9671,
                longitude: 135.7727,
                mood: .magical,
                weather: .sunny,
                temperature: "18°C",
                photos: [
                    MemoryPhoto(presetName: "kyoto_temple", caption: "Early morning silence under the vermilion torii gates")
                ],
                tags: ["#kyoto", "#fushimiinari", "#sunrise", "#shrine"],
                rating: 5,
                isFavorite: true
            ),
            MemoryEntry(
                id: UUID(uuidString: "aaaa1111-0000-0000-0000-000000000002")!,
                tripId: kyotoTrip.id,
                title: "Midnight Ramen in Pontocho Alley",
                story: "Got pleasantly lost wandering the narrow, lantern-lit cobblestone alleyways alongside the Kamogawa River. Slipped into an eight-seat ramen shop tucked behind a noren curtain. The tonkotsu broth was rich, velvety, and simmered for over 16 hours. The elderly chef smiled warmly when we finished every last drop.",
                date: calendar.date(byAdding: .day, value: -10, to: now)!,
                locationName: "Pontocho Alley, Kyoto",
                country: "Japan",
                latitude: 35.0063,
                longitude: 135.7712,
                mood: .foodie,
                weather: .partlyCloudy,
                temperature: "14°C",
                photos: [
                    MemoryPhoto(presetName: "kyoto_temple", caption: "Hidden ramen bar behind red paper lanterns")
                ],
                tags: ["#ramen", "#pontocho", "#foodie", "#nightwalk"],
                rating: 5,
                isFavorite: true
            ),
            MemoryEntry(
                id: UUID(uuidString: "bbbb2222-0000-0000-0000-000000000001")!,
                tripId: amalfiTrip.id,
                title: "Cliffside Morning in Positano",
                story: "Fresh espresso and warm sfogliatella on our terrace overlooking pastel houses cascading down the limestone cliff into the sparkling cobalt Tyrrhenian Sea. The scent of wild lemon blossoms drifting up in the morning breeze is something that will stay with me forever.",
                date: calendar.date(byAdding: .day, value: -44, to: now)!,
                locationName: "Positano Cliffside, Amalfi Coast",
                country: "Italy",
                latitude: 40.6281,
                longitude: 14.4850,
                mood: .peaceful,
                weather: .sunny,
                temperature: "25°C",
                photos: [
                    MemoryPhoto(presetName: "amalfi_coast", caption: "Pastel houses tumbling down into the Tyrrhenian Sea")
                ],
                tags: ["#positano", "#amalfi", "#seaview", "#espresso"],
                rating: 5,
                isFavorite: true
            ),
            MemoryEntry(
                id: UUID(uuidString: "bbbb2222-0000-0000-0000-000000000002")!,
                tripId: amalfiTrip.id,
                title: "Cruising Past the Faraglioni Arches",
                story: "Chartered a wooden gozzo boat around the island of Capri. We steered right through the center of the giant Faraglioni rock archway and plunged into the electric-blue waters of the secluded coves. Drank ice-cold limoncello as the golden sun dipped behind the jagged cliffs.",
                date: calendar.date(byAdding: .day, value: -40, to: now)!,
                locationName: "Faraglioni Rocks, Capri",
                country: "Italy",
                latitude: 40.5472,
                longitude: 14.2526,
                mood: .adventurous,
                weather: .sunny,
                temperature: "27°C",
                photos: [
                    MemoryPhoto(presetName: "amalfi_coast", caption: "Sailing through the natural arch at Faraglioni")
                ],
                tags: ["#capri", "#faraglioni", "#boat", "#swimming"],
                rating: 5,
                isFavorite: false
            ),
            MemoryEntry(
                id: UUID(uuidString: "cccc3333-0000-0000-0000-000000000001")!,
                tripId: swissTrip.id,
                title: "Mirror Reflection at Lake Riffelsee",
                story: "Took the cogwheel train up to Rotenboden and hiked down toward Lake Riffelsee. The air was crisp, razor-sharp, and completely silent. When the mountain breeze suddenly stopped, the mirror surface of the lake reflected the Matterhorn in absolute perfection. Sat on a granite boulder eating Swiss chocolate for an hour.",
                date: calendar.date(byAdding: .day, value: -87, to: now)!,
                locationName: "Lake Riffelsee, Zermatt",
                country: "Switzerland",
                latitude: 45.9818,
                longitude: 7.7788,
                mood: .amazed,
                weather: .sunny,
                temperature: "11°C",
                photos: [
                    MemoryPhoto(presetName: "swiss_alps", caption: "Mirror reflection of the Matterhorn in calm alpine water")
                ],
                tags: ["#matterhorn", "#zermatt", "#hiking", "#alps"],
                rating: 5,
                isFavorite: true
            )
        ]

        return (trips, memories)
    }
}
