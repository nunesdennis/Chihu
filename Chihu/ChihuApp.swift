//
//  ChihuApp.swift
//  Chihu
//
//

import SwiftUI
import SwiftData

@main
struct ChihuApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ShelfItemCache.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
