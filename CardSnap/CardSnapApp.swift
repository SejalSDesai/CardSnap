import SwiftUI
import SwiftData

@main
struct CardSnapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([BusinessCard.self])
        let storeURL = URL.applicationSupportDirectory.appending(path: "CardSnap.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Schema changed (e.g. renamed model) — wipe and start fresh
            try? FileManager.default.removeItem(at: storeURL)
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(sharedModelContainer)
    }
}
