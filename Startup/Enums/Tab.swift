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
    case search = "Search"
    
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
            return "tv.inset.filled"
        case .favorites:
            return "heart"
        case .search:
            return "magnifyingglass"
        }
    }
}

extension Tab {
    static let watch: [Tab] = [.movies, .tv, .favorites, .liveTV]
}
