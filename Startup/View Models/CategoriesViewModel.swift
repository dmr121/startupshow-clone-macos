//
//  CategoriesViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class CategoriesViewModel {
    var categories = [CategoryViewModel]()
    var fetchingCategories = true
    var lastFetched: Date?
}

// MARK: Public methods
extension CategoriesViewModel {
    @MainActor
    func getMovieURL(withId id: String, profile: Profile?) async throws -> String {
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
    func getCategories(profile: Profile?) async throws {
        // Make sure 10 minutes have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 { return }
        lastFetched = Date()
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/movies/categories")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let categories = try json["data"].arrayValue.compactMap { jsonC in
            return try Category(from: jsonC)
        }
        
        withAnimation { self.categories = categories.map { CategoryViewModel($0) } }
        
        // Get all movies from all categories
        try await withThrowingTaskGroup(of: Void.self) { group in
            self.categories.forEach { category in
                if category.id == "1" {
                    group.addTask {
                        try await category.getMovies(profile: profile)
                    }
                }
            }
            
            for try await _ in group {
                print("Got category movies")
            }
        }
    }
}
