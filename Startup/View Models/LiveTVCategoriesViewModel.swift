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
    var fetchingCategories = true
    var lastFetched: Date?
}

// MARK: Public methods
extension LiveTVCategoriesViewModel {
    @MainActor
    func getCategories(profile: Profile?) async throws {
        // Make sure 10 hours have passed
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 10 * 60 * 60 { return }
        lastFetched = Date()
        
        withAnimation { fetchingCategories = true }
        defer {
            withAnimation { fetchingCategories = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/livetv/categories")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let categories = try json["data"].arrayValue.compactMap { jsonC in
            return try Category(from: jsonC)
        }
        
        withAnimation { self.categories = categories }
    }
}
