//
//  Tab.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

enum Tab: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tv = "TV"
    case favorites = "Favorites"
    case liveTV = "Live TV"
    
    var id: Self {
        return self
    }
    
    var icon: String {
        switch self {
        case .movies:
            return "movieclapper"
        case .tv:
            return "tv"
        case .liveTV:
            return "antenna.radiowaves.left.and.right"
        case .favorites:
            return "heart"
        }
    }
}

extension Tab {
    static let watch: [Tab] = [.movies, .tv, .favorites, .liveTV]
}
