//
//  SearchViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/24/24.
//

import SwiftUI
import Combine
import SwiftyJSON
import KeychainAccess

enum SearchType: String, CaseIterable, Identifiable, Hashable {
    case movies = "Movies"
    case tv = "TV Shows"
    case liveTV = "Live TV"
    
    var id: Self {
        return self
    }
}

class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var type = SearchType.movies
    @Published var media = [MediaViewModel]()
    @Published var liveTV = [LiveTVChannelViewModel]()
    @Published var fetching = true
    
    private var querySubscriber: AnyCancellable!
    private var typeSubscriber: AnyCancellable!
    
    private lazy var queryPublisher: AnyPublisher<String, Never> = {
        $searchQuery
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { return $0.trimmed() }
            .eraseToAnyPublisher()
    }()
    
    private lazy var typePublisher: AnyPublisher<SearchType, Never> = {
        $type
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }()
    
    init(profile: Profile?) {
        querySubscriber = queryPublisher
            .dropFirst(1)
            .sink(receiveValue: { newQuery in
                self.search(withQuery: newQuery, profile: profile)
            })
        
        typeSubscriber = typePublisher
            .dropFirst(1)
            .sink(receiveValue: { _ in
                self.media = []
                self.liveTV = []
                let trimmed = self.searchQuery.trimmed()
                self.search(withQuery: trimmed, profile: profile)
            })
    }
}

// MARK: Private methods
extension SearchViewModel {
    func search(withQuery query: String, profile: Profile?) {
        Task {
            do {
                switch type {
                case .movies:
                    try await self.searchMovies(withQuery: query, profile: profile)
                case .tv:
                    try await self.searchTVShows(withQuery: query, profile: profile)
                case .liveTV:
                    try await self.searchLiveTVChannels(withQuery: query, profile: profile)
                }
            } catch {
                print("🚨 Error searching: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Public methods
extension SearchViewModel {
    @MainActor
    func searchAll(withQuery query: String, profile: Profile?) async throws {
        // Get all search results from all media types
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.searchMovies(withQuery: query, profile: profile)
                try await self.searchTVShows(withQuery: query, profile: profile)
            }
            
            for try await _ in group {
                print("Got category tv shows")
            }
        }
    }
    
    @MainActor
    func searchMovies(withQuery query: String, profile: Profile?) async throws {
        let trimmed = query.trimmed()
        guard trimmed.count > 0 else { 
            withAnimation { self.media = [] }
            throw "Bad query"
        }
        
        withAnimation { fetching = true }
        defer {
            withAnimation { fetching = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/movie/search/\(trimmed)?use_lang_limits=0")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let movies = try json["data"].arrayValue.compactMap { jsonM in
            return try Media(from: jsonM)
        }
        
        withAnimation { self.media = movies.map { MediaViewModel($0, .movie) } }
    }
    
    @MainActor
    func searchTVShows(withQuery query: String, profile: Profile?) async throws {
        let trimmed = query.trimmed()
        guard trimmed.count > 0 else { 
            withAnimation { self.media = [] }
            throw "Bad query"
        }
        
        withAnimation { fetching = true }
        defer {
            withAnimation { fetching = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/tvshow/search/\(trimmed)?use_lang_limits=0")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        if let profile {
            request.setValue("\(profile.profileNumber)", forHTTPHeaderField: "X-API-PROFILE")
        }
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let tvShows = try json["data"].arrayValue.compactMap { jsonTV in
            return try Media(from: jsonTV)
        }
        
        withAnimation { self.media = tvShows.map { MediaViewModel($0, .tv(0, 0, 0)) } }
    }
    
    @MainActor
    func searchLiveTVChannels(withQuery query: String, profile: Profile?) async throws {
        let trimmed = query.trimmed()
        guard trimmed.count > 0 else {
            withAnimation { self.media = [] }
            throw "Bad query"
        }
        
        withAnimation { fetching = true }
        defer {
            withAnimation { fetching = false }
        }
        
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/info/livetv/search/\(trimmed)?use_lang_limits=0")!
        
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
        
        withAnimation { self.liveTV = channels.map { LiveTVChannelViewModel($0) } }
    }
}
