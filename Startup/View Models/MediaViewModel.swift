//
//  MediaViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

enum MediaType {
    case movie
    case tv(Int, Int)
    
    var slug: String {
        switch self {
        case .movie:
            return "movie"
        case .tv:
            return "tvshow"
        }
    }
    
    var season: Int? {
        switch self {
        case .tv(let season, _):
            return season
        default:
            return nil
        }
    }
    
    var episode: Int? {
        switch self {
        case .tv(_, let episode):
            return episode
        default:
            return nil
        }
    }
}

@Observable class MediaViewModel: Identifiable, Hashable {
    var value: Media
    var favoritingMedia = false
    var type: MediaType
    
    init(_ value: Media, _ type: MediaType) {
        self.value = value
        self.type = type
    }
    
    var id: String {
        return value.id
    }
    
    static func == (lhs: MediaViewModel, rhs: MediaViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: Public methods
extension MediaViewModel {
    @MainActor
    func getMediaURL(profile: Profile?, season: Int? = nil, episode: Int? = nil) async throws -> String {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        var url: URL
        
        switch type {
        case .movie:
            url = URL(string: "\(K.apiURLBase)/play/movie/\(id)")!
        case .tv:
            guard let season, let episode else { throw "Episode and season required" }
            url = URL(string: "\(K.apiURLBase)/play/tvshow/\(id)/\(season)/\(episode)")!
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let secureLink = json["data"]["secure_link"].string
        
        if let secureLink { return secureLink }
        throw "Couldn't get secure link"
    }
    
    @MainActor
    func favorite(profile: Profile?) async throws -> String? {
        withAnimation { favoritingMedia = true }
        defer {
            withAnimation { favoritingMedia = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/\(type.slug)/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        value.toggleFavorite(to: true)
        
        let json = try JSON(data: responseData)
        return json["message"].string
    }
    
    @MainActor
    func unfavorite(profile: Profile?) async throws -> String? {
        withAnimation { favoritingMedia = true }
        defer {
            withAnimation { favoritingMedia = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/\(type.slug)/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        value.toggleFavorite(to: false)
        
        let json = try JSON(data: responseData)
        return json["message"].string
    }
}
