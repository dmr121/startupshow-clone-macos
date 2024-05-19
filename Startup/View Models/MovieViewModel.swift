//
//  MovieViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class MovieViewModel: Identifiable, Hashable {
    var value: Movie
    var favoritingMovie = false
    
    init(_ value: Movie) {
        self.value = value
    }
    
    var id: String {
        return value.id
    }
    
    static func == (lhs: MovieViewModel, rhs: MovieViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: Public methods
extension MovieViewModel {
    @MainActor
    func getMovieURL(profile: Profile?) async throws -> String {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/play/movie/\(id)")!
        
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
    func favorite(profile: Profile?) async throws {
        withAnimation { favoritingMovie = true }
        defer {
            withAnimation { favoritingMovie = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/movie/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        
        value.toggleFavorite(to: true)
    }
    
    @MainActor
    func unfavorite(profile: Profile?) async throws {
        withAnimation { favoritingMovie = true }
        defer {
            withAnimation { favoritingMovie = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/favorite/movie/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        
        value.toggleFavorite(to: false)
    }
}
