//
//  Profile.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/15/24.
//

import Foundation
import SwiftyJSON

struct Profile: Identifiable, Hashable, Encodable {
    let userId: Int
    let profileNumber: Int
    let name: String
    let avatarURL: URL?
    let type: String
    let createdAt: Date
    
    var id: Int {
        return profileNumber
    }
    
    init(from json: JSON) throws {
        userId = json["user_id"].intValue
        profileNumber = json["profile_number"].intValue
        name = json["name"].stringValue
        
        if let avatarURLString = json["avatar"].string {
            avatarURL = URL(string: avatarURLString)
        } else { avatarURL = nil }
        
        type = json["type"].stringValue
        
        let createdAtString = json["created_at"].stringValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        createdAt = dateFormatter.date(from: createdAtString)!
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case profileNumber = "profile_number"
        case name
        case avatarURL = "avatar"
        case type
        case createdAt = "created_at"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(profileNumber, forKey: .profileNumber)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL?.absoluteString, forKey: .avatarURL)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt.formatted("yyyy-MM-dd'T'HH:mm:ssZZZZZ"), forKey: .createdAt)
    }
}
