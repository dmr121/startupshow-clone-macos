//
//  Movie.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import Foundation
import SwiftyJSON

struct Media: Identifiable, Equatable, Hashable {
    let imdb_id: String
    let tvdb_id: Int
    let tmdb_id: Int
    let trakt_id: Int
    let type: String
    let title: String
    let year: Int
    let released: String
    let mpa: String
    var history: History?
    var is_favorite: Bool?
    let meta: Meta
    let seasons: [[Episode]]?
    let languages: [String]
    
    init(from json: JSON) throws {
        imdb_id = json["imdb_id"].stringValue
        tvdb_id = json["tvdb_id"].intValue
        tmdb_id = json["tmdb_id"].intValue
        trakt_id = json["trakt_id"].intValue
        type = json["type"].stringValue
        title = json["title"].stringValue
        year = json["year"].intValue
        released = json["released"].stringValue
        mpa = json["mpa"].stringValue
        history = try? History(from: json["history"])
        is_favorite = json["is_favorite"].bool
        meta = try Meta(from: json["meta"])
        
        let seasons = try? json["meta_episodes"].array?.compactMap { season in
            try season.arrayValue.map { episode in try Episode(from: episode) }
        }
        if (seasons?.count ?? 0) > 0 {
            self.seasons = seasons
        } else { self.seasons = nil }
        
        languages = json["languages"].arrayObject?.map { $0 as! String } ?? []
    }
    
    var id: String {
        return imdb_id
    }
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Public methods
extension Media {
    mutating func toggleFavorite(to favorite: Bool? = nil) {
        guard let favorite else {
            is_favorite = !(is_favorite ?? false)
            return
        }
        is_favorite = favorite
    }
}

extension Media {
    struct Meta: Identifiable, Hashable {
        let imdb_id: String
        let title: String
        let year: String
        let released: String
        let votes: String
        let rank: Double
        let plot: String
        let poster: URL?
        let type: Int
        let runtime: String
        let genres: String
        let company: String
        let director: String?
        let writer: String?
        let cast: String
        let tmdb_id: Int
        let fanart: URL?
        let trailer: URL?
        let mppa: String
        let trakt_id: Int
        let screenshot: URL?
        
        init(from json: JSON) throws {
            imdb_id = json["imdb_id"].stringValue
            title = json["title"].stringValue
            year = json["year"].stringValue
            released = json["released"].stringValue
            votes = json["votes"].stringValue
            rank = json["rank"].doubleValue
            plot = json["plot"].stringValue
            poster = json["poster"].url
            type = json["type"].intValue
            runtime = json["runtime"].stringValue
            genres = json["genres"].stringValue
            company = json["company"].stringValue
            let directorString = json["director"].stringValue
            director = directorString.trimmed().count > 0 ? directorString: nil
            let writerString = json["writer"].stringValue
            writer = writerString.trimmed().count > 0 ? writerString: nil
            cast = json["cast"].stringValue
            tmdb_id = json["tmdb_id"].intValue
            fanart = json["fanart"].url
            trailer = json["trailer"].url
            mppa = json["mppa"].stringValue
            trakt_id = json["trakt_id"].intValue
            screenshot = json["screenshot"].url
        }
        
        var id: String {
            return imdb_id
        }
    }
    
    struct History: Identifiable, Hashable {
        var seconds: Int?
        let imdb_id: String
        let type: String
        var recent: EpisodeHistory?
        var data: [EpisodeHistory]?
        
        init(from json: JSON) throws {
            seconds = json["data"]["seconds"].int
            imdb_id = json["imdb_id"].stringValue
            type = json["type"].stringValue
            recent = try? EpisodeHistory(from: json["recent"])
            
            var dataArray = [EpisodeHistory]()
            for (_, subJson) in json["data"].dictionaryValue {
                if let entry = try? EpisodeHistory(from: subJson) {
                    dataArray.append(entry)
                }
            }
        
            self.data = dataArray.count > 0 ? dataArray: nil
        }
        
        var id: String {
            return imdb_id
        }
    }
    
    struct EpisodeHistory: Hashable {
        var seconds: Int
        let looksWatched : Bool?
        let episode: Int
        let season: Int
        
        init(from json: JSON) throws {
            seconds = json["seconds"].intValue
            looksWatched = json["looks_watched"].bool
            episode = json["episode"].intValue
            season = json["season"].intValue
        }
    }
    
    struct Episode: Identifiable, Hashable {
        let duration: Int
        let episode: Int
        let fanart: URL?
        let plot: String
        let poster: URL?
        let released: Date?
        let screenshot: URL?
        let season: Int
        let title: String?
        
        init(from json: JSON) throws {
            duration = json["duration"].intValue
            episode = json["episode"].intValue
            fanart = json["fanart"].url
            plot = json["plot"].stringValue
            poster = json["poster"].url
            
            let releasedAtString = json["released"].stringValue
            if let epoch = Double(releasedAtString) {
                released = Date(timeIntervalSince1970: epoch)
            } else { released = nil }
            
            screenshot = json["screenshot"].url
            season = json["season"].intValue
            title = json["title"].string
        }
        
        var id: String {
            return "\(season) \(episode)"
        }
    }
}
