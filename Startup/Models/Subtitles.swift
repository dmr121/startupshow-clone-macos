//
//  Subtitles.swift
//  Startup
//
//  Created by David Rozmajzl on 5/21/24.
//

import Foundation
import SwiftyJSON

struct Subtitles: Equatable {
    let imdb_id: String
    let type: String
    let episode: Int?
    let season: Int?
    let urls: [String: URL]?
    
    init(from json: JSON) throws {
        imdb_id = json["imdb_id"].stringValue
        type = json["type"].stringValue
        season = json["season"].int
        episode = json["episode"].int
        
        var urlsArray = [String: URL]()
        for (key, subJson) in json["data"].dictionaryValue {
            urlsArray[key] = subJson.url!
        }
        
        urls = urlsArray
    }
}
