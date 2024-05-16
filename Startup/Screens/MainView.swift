//
//  MainView.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

struct MainView: View {
    @Environment(Authentication.self) private var auth
    
    @State private var tab: Tab? = .movies
    @State private var searchQuery: String = ""
    @State private var showLogoutAlert = false
    
    var body: some View {
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
    }
}

// MARK: Views
extension MainView {
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
        .toolbar {
            Button {
                showLogoutAlert = true
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Logout") {
                Task {
                    do {
                        try await auth.logout()
                    } catch {
                        print("🚨 Error logging out: \(error.localizedDescription)")
                    }
                }
            }
        }, message: {
            Text("Are you sure you want to logout?")
        })
    }
}
