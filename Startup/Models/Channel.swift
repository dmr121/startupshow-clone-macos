//
//  Channel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/27/24.
//

import Foundation
import SwiftyJSON

struct Channel: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let categories: [Int]
    var is_favorite: Bool?
    let logo: URL?
    let now: Schedule?
    let next: Schedule?
    let channels: [SubChannel]?
    
    init(from json: JSON) throws {
        id = json["id"].stringValue
        name = json["name"].stringValue
        categories = json["categories"].arrayValue.map { $0.intValue }
        is_favorite = json["is_favorite"].bool
        logo = json["logo"].url
        now = try? Schedule(from: json["now"]["now"])
        next = try? Schedule(from: json["now"]["next"])
        
        let channels = try? json["channels"].array?.compactMap { channel in
            try SubChannel(from: channel)
        }
        if (channels?.count ?? 0) > 0 {
            self.channels = channels
        } else { self.channels = nil }
    }
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Public methods
extension Channel {
    mutating func toggleFavorite(to favorite: Bool? = nil) {
        guard let favorite else {
            is_favorite = !(is_favorite ?? false)
            return
        }
        is_favorite = favorite
    }
}

extension Channel {
    struct Schedule: Hashable {
        let start: Date?
        let stop: Date?
        let title: String?
        let desc: String?
        
        init(from json: JSON) throws {
            let dateFormatter = DateFormatter()
            let startString = json["start"].stringValue
            dateFormatter.dateFormat = "yyyyMMddHHmmss Z"
            start = dateFormatter.date(from: startString)
            
            let stopString = json["stop"].stringValue
            dateFormatter.dateFormat = "yyyyMMddHHmmss Z"
            stop = dateFormatter.date(from: stopString)
            
            title = json["title"].string
            desc = json["desc"].string
        }
    }
    
    struct SubChannel: Hashable, Identifiable {
        let id: Int
        let sourceName: String
        let sourceServer: String
        let active: Bool
        let status: Int
        let hd: Int
        
        init(from json: JSON) throws {
            id = json["id"].intValue
            sourceName = json["source_name"].stringValue
            sourceServer = json["source_server"].stringValue
            active = json["active"].boolValue
            status = json["status"].intValue
            hd = json["hd"].intValue
        }
    }
}
