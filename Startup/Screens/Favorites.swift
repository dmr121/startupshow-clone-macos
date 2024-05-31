//
//  Favorites.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

fileprivate let columnCount = 6

struct Favorites: View {
    @Environment(Authentication.self) private var auth
    @Environment(FavoritesViewModel.self) private var favorites
    
    @State private var selectedMedia: MediaViewModel?
    @State private var selectedChannel: LiveTVChannelViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    if favorites.movies.count > 0 {
                        MediaList(favorites.movies, "Movies", geometry: geometry)
                    }
                    
                    if favorites.tvShows.count > 0 {
                        MediaList(favorites.tvShows, "TV Shows", padding: 8, geometry: geometry)
                    }
                    
                    if favorites.liveTV.count > 0 {
                        Section {
                            LazyVGrid(columns: channelGridColumns, spacing: 10) {
                                ForEach(favorites.liveTV) { channel in
                                    LiveTVChannelTile(channel, selectedChannel: $selectedChannel)
                                }
                            }
                            .padding(10)
                        } header: {
                            Text("Live TV Channels")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 11)
                                .padding(.bottom, -12)
                                .padding(.leading, 6 * 2)
                        }
                    }
                }
                .padding(.vertical)
                .blur(radius: favorites.fetchingFavorites ? 20: 0)
                .disabled(favorites.fetchingFavorites)
            }
            .sheet(item: $selectedMedia) { tvShow in
                MediaDetailModal(tvShow)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
            .sheet(item: $selectedChannel) { channel in
                LiveTVChannelModal(channel)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
        }
        .task {
            do {
                try await favorites.getFavorites(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Views
extension Favorites {
    @ViewBuilder private func MediaList(_ media: [MediaViewModel], _ title: String, padding: CGFloat = 6, geometry: GeometryProxy) -> some View {
        Section {
            Carousel(media, columns: columnCount, padding: padding, geometry: geometry) { media in
                MediaCard(media, selected: $selectedMedia)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(2/3, contentMode: .fill)
            }
        } header: {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 11)
                .padding(.bottom, -12)
                .padding(.leading, 6 * 2)
        }
    }
}

// MARK: Private methods
extension Favorites {
    private func getFavorites() async {
        do {
            try await favorites.getFavorites(profile: auth.profile)
        } catch {
            print("🚨 Error fetching categories: \(error.localizedDescription)")
        }
    }
}
