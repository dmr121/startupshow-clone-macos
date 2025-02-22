//
//  MediaViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

enum MediaType: Equatable {
    case movie
    case tv(Int, Int, Int)
    
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
        case .tv(let season, _, _):
            return season
        default:
            return nil
        }
    }
    
    var episode: Int? {
        switch self {
        case .tv(_, let episode, _):
            return episode
        default:
            return nil
        }
    }
    
    var duration: Int? {
        switch self {
        case .tv(_, _, let duration):
            return duration
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
    func markPosition(_ position: Int, profile: Profile?, season: Int? = nil, episode: Int? = nil) async throws -> String? {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        var url: URL
        
        switch type {
        case .movie:
            url = URL(string: "\(K.apiURLBase)/history/movie/position/\(id)/\(position)")!
        case .tv:
            guard let season, let episode else { throw "Episode and season required" }
            url = URL(string: "\(K.apiURLBase)/history/tvshow/position/\(id)/\(season)/\(episode)/\(position)/0")!
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        
        try await getMedia(profile: profile)
        
        return json["message"].string
    }
    
    @MainActor
    func getMedia(profile: Profile?) async throws {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        var url: URL
        
        switch type {
        case .movie:
            url = URL(string: "\(K.apiURLBase)/info/movies/\(id)")!
        case .tv:
            url = URL(string: "\(K.apiURLBase)/info/tvshows/\(id)")!
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        guard json["data"].count == 1 else { return }
        
        let media = try Media(from: json["data"][0])
        
        withAnimation { self.value = media }
    }
    
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
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let secureLink = json["data"]["secure_link"].string
        
        if let secureLink { return secureLink }
        throw "Couldn't get secure link"
    }
    
    @MainActor
    func getSubtitles(profile: Profile?, season: Int? = nil, episode: Int? = nil) async throws -> [Subtitles] {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        var url: URL
        
        switch type {
        case .movie:
            url = URL(string: "\(K.apiURLBase)/subtitles/movie/\(id)")!
        case .tv:
            guard let season, let episode else { throw "Episode and season required" }
            url = URL(string: "\(K.apiURLBase)/subtitles/tvshow/\(id)/\(season)/\(episode)")!
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        
        let subtitles = try json["data"].arrayValue.compactMap { jsonS in
            return try Subtitles(from: jsonS)
        }
        
        return subtitles
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
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
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
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        value.toggleFavorite(to: false)
        
        let json = try JSON(data: responseData)
        return json["message"].string
    }
}
