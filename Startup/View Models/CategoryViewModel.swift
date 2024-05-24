//
//  CategoryViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class CategoryViewModel: Identifiable {
    var value: Category
    var media: [MediaViewModel]
    var fetchingMedia: Bool
    
    init(_ value: Category, media: [MediaViewModel] = [MediaViewModel]()) {
        self.value = value
        self.media = media
        self.fetchingMedia = true
    }
    
    var id: String {
        return value.id
    }
}

// MARK: Public methods
extension CategoryViewModel {
    @MainActor
    func getMovies(profile: Profile?) async throws {
        withAnimation { fetchingMedia = true }
        defer {
            withAnimation { fetchingMedia = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/movies/items/\(id)/0/50?use_lang_limits=0")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let movies = try json["data"]["infos"].arrayValue.compactMap { jsonM in
            return try Media(from: jsonM)
        }
        
        withAnimation { self.media = movies.map { MediaViewModel($0, .movie) } }
    }
    
    @MainActor
    func getTVShows(profile: Profile?) async throws {
        withAnimation { fetchingMedia = true }
        defer {
            withAnimation { fetchingMedia = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/tvshow/items/\(id)/0/50?use_lang_limits=0")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let tvShows = try json["data"]["infos"].arrayValue.compactMap { jsonTV in
            return try Media(from: jsonTV)
        }
        
        withAnimation { self.media = tvShows.map { MediaViewModel($0, .tv(0,0)) } }
    }
}
