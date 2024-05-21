//
//  FavoritesViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/20/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class FavoritesViewModel {
    var movies = [MediaViewModel]()
    var tvShows = [MediaViewModel]()
//    var liveTV
    var fetchingFavorites = true
    var lastFetched: Date?
}

// MARK: Public methods
extension FavoritesViewModel {
    @MainActor
    func getFavorites(profile: Profile?) async throws {
        // Make sure 10 minutes have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 { return }
        lastFetched = Date()
        
        withAnimation { fetchingFavorites = true }
        defer {
            withAnimation { fetchingFavorites = false }
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.getMovies(profile: profile)
            }
            group.addTask {
                try await self.getTVShows(profile: profile)
            }
            
            for try await _ in group {
                print("Got favorites")
            }
        }
    }
}

// MARK: Private methods
extension FavoritesViewModel {
    @MainActor
    func getMovies(profile: Profile?) async throws {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/movies/list/0/50/alphabetic")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let movies = try json["data"].arrayValue.compactMap { jsonM in
            return try Media(from: jsonM)
        }
        
        withAnimation { self.movies = movies.map { MediaViewModel($0, .movie) } }
    }
    
    @MainActor
    func getTVShows(profile: Profile?) async throws {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/tvshow/list/0/50/alphabetic")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let tvShows = try json["data"].arrayValue.compactMap { jsonT in
            return try Media(from: jsonT)
        }
        
        withAnimation { self.tvShows = tvShows.map { MediaViewModel($0, .tv(0, 0)) } }
    }
    
    // livetv -> https://tvnow.best/api/favorite/livetv/list/0/50/alphabetic?include_full_tv_guide=0
}
