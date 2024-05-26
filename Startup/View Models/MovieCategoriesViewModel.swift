//
//  MovieCategoriesViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class MovieCategoriesViewModel {
    var categories = [CategoryViewModel]()
    var fetchingCategories = true
    var lastFetched: Date?
}

// MARK: Public methods
extension MovieCategoriesViewModel {    
    @MainActor
    func getCategories(profile: Profile?) async throws {
        // Make sure 10 minutes have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 { return }
        
        withAnimation { fetchingCategories = true }
        defer {
            withAnimation { fetchingCategories = false }
        }
        
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
                if category.id == "7" {
                    group.addTask {
                        try await category.getMovies(profile: profile)
                    }
                }
            }
            
            for try await _ in group {
                print("Got category movies")
            }
        }
        
        lastFetched = Date()
    }
}
