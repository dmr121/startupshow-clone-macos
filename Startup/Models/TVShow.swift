//
//  TVShow.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import Foundation
import SwiftyJSON

struct TVShow: Identifiable, Equatable, Hashable {
    let imdb_id: String
    let tvdb_id: Int
    let tmdb_id: Int
    let trakt_id: Int
    let type: String
    let title: String
    let year: Int
    let released: String
    let mpa: String
    let history: History?
    var is_favorite: Bool?
    let meta: Meta
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
        languages = json["languages"].arrayObject?.map { $0 as! String } ?? []
    }
    
    var id: String {
        return imdb_id
    }
    
    static func == (lhs: TVShow, rhs: TVShow) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Public methods
extension TVShow {
    mutating func toggleFavorite(to favorite: Bool? = nil) {
        guard let favorite else {
            is_favorite = !(is_favorite ?? false)
            return
        }
        is_favorite = favorite
    }
}

extension TVShow {
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
        let director: String
        let writer: String
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
            director = json["director"].stringValue
            writer = json["writer"].stringValue
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
        let seconds: Int?
        let imdb_id: String
        let type: String
        
        init(from json: JSON) throws {
            seconds = json["data"]["seconds"].int
            imdb_id = json["imdb_id"].stringValue
            type = json["type"].stringValue
        }
        
        var id: String {
            return imdb_id
        }
    }
}
