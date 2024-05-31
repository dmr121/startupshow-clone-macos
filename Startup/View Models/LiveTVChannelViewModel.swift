//
//  LiveTVChannelViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/30/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class LiveTVChannelViewModel: Identifiable, Hashable {
    var value: Channel
    var favoritingMedia = false
    var fetchingEpisodeGuide = true
    
    init(_ value: Channel) {
        self.value = value
    }
    
    var id: String {
        return value.id
    }
    
    static func == (lhs: LiveTVChannelViewModel, rhs: LiveTVChannelViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: Public methods
extension LiveTVChannelViewModel {
    @MainActor
    func getEpisodeGuide() async throws -> [EPG] {
        withAnimation { fetchingEpisodeGuide = true }
        defer {
            withAnimation { fetchingEpisodeGuide = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/epg/\(id)")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        guard json["data"].array?.first != nil else { throw "No Episode Guide data" }
        
        let epg = json["data"].arrayValue.reduce([EPG]()) { partialResult, jsonEPG in
            guard jsonEPG["id"].string == id else { return partialResult }
            guard let full = jsonEPG["full"].array else { return partialResult }
            
            do {
                let newEPGs = try full.compactMap({ json in
                    return try EPG(from: json)
                })
                var copy = partialResult
                copy.append(contentsOf: newEPGs)
                return copy
            } catch {
                return partialResult
            }
        }
       
        return epg
    }
    
    @MainActor
    func getMediaURL() async throws -> String {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/play/livetv.epg/\(id).m3u8")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
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
        
        let url = URL(string: "\(K.apiURLBase)/favorite/livetv/\(id)")!
        
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
        
        let url = URL(string: "\(K.apiURLBase)/favorite/livetv/\(id)")!
        
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
