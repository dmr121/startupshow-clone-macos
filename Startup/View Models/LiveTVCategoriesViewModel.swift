//
//  LiveTVCategoriesViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/24/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class LiveTVCategoriesViewModel {
    var categories = [Category]()
    var selectedCategory: Category?
    var categoryChannels = [LiveTVChannelViewModel]()
    
    var fetchingCategories = true
    var fetchingChannels = true
    var lastFetched: Date?
}

// MARK: Public methods
extension LiveTVCategoriesViewModel {
    @MainActor
    func getChannels(for category: Category, profile: Profile?) async throws {
        withAnimation { fetchingChannels = true }
        defer {
            withAnimation { fetchingChannels = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/livetv/categories/\(category.id)")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let channels = try json["data"].arrayValue.compactMap { jsonC in
            return try Channel(from: jsonC)
        }
        
        withAnimation { self.categoryChannels = channels.map { LiveTVChannelViewModel($0) } }
    }
    
    @MainActor
    func getCategories(profile: Profile?) async throws {
        // Make sure 10 hours have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 * 60 { return }
        
        withAnimation { fetchingCategories = true }
        defer {
            withAnimation { fetchingCategories = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/livetv/categories")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let categories = try json["data"].arrayValue.compactMap { jsonC in
            return try Category(from: jsonC)
        }
        
        withAnimation { self.categories = categories }
        
        lastFetched = Date()
    }
}
