//
//  StartupApp.swift
//  Startup
//
//  Created by David Rozmajzl on 5/14/24.
//

import SwiftUI
import SwiftData

@main
struct StartupApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var auth = Authentication()
    @State private var movieCategoriesViewModel = MovieCategoriesViewModel()
    @State private var tvCategoriesViewModel = TVCategoriesViewModel()
    @State private var favoritesViewModel = FavoritesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800)
                .frame(minHeight: 450)
                .environment(auth)
                .environment(movieCategoriesViewModel)
                .environment(tvCategoriesViewModel)
                .environment(favoritesViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
