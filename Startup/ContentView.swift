//
//  ContentView.swift
//  Startup
//
//  Created by David Rozmajzl on 5/14/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(Authentication.self) private var auth
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var tab: Tab? = .movies
    @State private var searchQuery: String = ""
    
    var body: some View {
        Group {
            //            if auth.authToken != nil,
            //               let expiration = auth.authTokenExpiration,
            //                expiration > Date() {
            NavigationSplitView {
                Sidebar()
                    .navigationSplitViewColumnWidth(min: 120, ideal: 180, max: 250)
                    .searchable(text: $searchQuery, placement: .sidebar)
            } detail: {
                Text("Select a tab.")
            }
            .task {
                // Get user
                // get profile data
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {print("HERE")}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            //                .transition(.scale)
            //            } else {
            //                Welcome()
            //                    .transition(.scale)
            //            }
        }
    }
}

// MARK: Views
extension ContentView {
    @ViewBuilder private func Sidebar() -> some View {
        List(selection: $tab) {
            Section("Watch") {
                ForEach(Tab.watch, id: \.self) { tab in
                    NavigationLink {
                        switch tab {
                        case .movies:
                            Movies()
                        case .tv:
                            TVShows()
                        case .liveTV:
                            LiveTV()
                        case .favorites:
                            Favorites()
                        }
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .contextMenu {
                        Button(action: {
                            print("Action \(tab)")
                        }){
                            Text("Action")
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
