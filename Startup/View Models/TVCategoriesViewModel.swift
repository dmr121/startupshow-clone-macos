//
//  TVCategoriesViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class TVCategoriesViewModel {
    var categories = [CategoryViewModel]()
    var fetchingCategories = true
    var lastFetched: Date?
}

// MARK: Public methods
extension TVCategoriesViewModel {
    @MainActor
    func getCategories(profile: Profile?) async throws {
        // Make sure 10 minutes have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 { return }
        
        withAnimation { fetchingCategories = true }
        defer {
            withAnimation { fetchingCategories = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/tvshows/categories")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let categories = try json["data"].arrayValue.compactMap { jsonC in
            return try Category(from: jsonC)
        }
        
        withAnimation { self.categories = categories.map { CategoryViewModel($0) } }
        
        // Get all tv shows from all categories
        try await withThrowingTaskGroup(of: Void.self) { group in
            self.categories.forEach { category in
                if category.id == "51" {
                    group.addTask {
                        try await category.getTVShows(profile: profile)
                    }
                }
            }
            
            for try await _ in group {
                print("Got category tv shows")
            }
        }
        
        lastFetched = Date()
    }
}
