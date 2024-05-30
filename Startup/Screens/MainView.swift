//
//  MainView.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

struct MainView: View {
    @Environment(Authentication.self) private var auth
    
    @State private var tab: Tab? = .liveTV
    @State private var navVisibility = NavigationSplitViewVisibility.doubleColumn
    @State private var showLogoutAlert = false
    
    @State private var navigation = Navigation()
    
    var body: some View {
        NavigationStack(path: $navigation.mediaPaths) {
            NavigationSplitView(columnVisibility: $navVisibility) {
                Sidebar()
                    .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 240)
            } detail: {
                Text("Select a tab.")
            }
            .navigationSplitViewStyle(.prominentDetail)
            .navigationDestination(for: MediaViewModel.self) { media in
                Watch(media)
            }
                        .navigationDestination(for: LiveTVChannelViewModel.self) { channel in
                            WatchLive(channel)
                        }
            .sheet(isPresented: $navigation.showSearchModel) {
                SearchModal(auth: auth)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(idealWidth: 750, idealHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
        }
        .environment(navigation)
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
                                .navigationTitle("Movies")
                                .onAppear(perform: showCursor)
                        case .tv:
                            TVShows()
                                .navigationTitle("TV")
                                .onAppear(perform: showCursor)
                        case .liveTV:
                            LiveTVNetworks()
                                .navigationTitle("Live TV")
                                .onAppear(perform: showCursor)
                        case .favorites:
                            Favorites()
                                .navigationTitle("Favorites")
                                .onAppear(perform: showCursor)
                        default:
                            EmptyView()
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
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    navigation.showSearchModel = true
                } label: {
                    Label(Tab.search.rawValue, systemImage: Tab.search.icon)
                }
                
                Button {
                    showLogoutAlert = true
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                }
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

// MARK: Private methods
extension MainView {
    private func showCursor() {
        NSCursor.unhide()
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            NSCursor.unhide()
        }
    }
}
