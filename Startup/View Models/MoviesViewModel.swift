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
    var movies: [Movie]
    var fetchingMovies: Bool
    
    init(_ value: Category, movies: [Movie] = [Movie](), fetchingMovies: Bool = true) {
        self.value = value
        self.movies = movies
        self.fetchingMovies = fetchingMovies
    }
    
    var id: String {
        return value.id
    }
}

// MARK: Public methods
extension CategoryViewModel {
    @MainActor
    func getMovies(profile: Profile?) async throws {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/movies/items/\(id)/0/50?use_lang_limits=0")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("X-API-PROFILE", forHTTPHeaderField: "\(profile.profileNumber)")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let movies = try json["data"]["infos"].arrayValue.compactMap { jsonM in
            return try Movie(from: jsonM)
        }
        
        withAnimation { self.movies = movies }
    }
}
