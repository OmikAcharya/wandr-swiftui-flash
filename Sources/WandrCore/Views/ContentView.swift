import SwiftUI

public struct ContentView: View {
    @StateObject private var store = TravelStore()

    public init() {}

    public var body: some View {
        TabView(selection: $store.selectedTab) {
            TripsView(store: store)
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
                .tag(0)

            TimelineFeedView(store: store)
                .tabItem {
                    Label("Diary", systemImage: "book.pages")
                }
                .tag(1)

            TravelMapView(store: store)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)

            TravelStatsView(store: store)
                .tabItem {
                    Label("Passport", systemImage: "globe.americas.fill")
                }
                .tag(3)
        }
        .tint(Color.wandrAccent)
        .background(Color.wandrBackground)
    }
}
