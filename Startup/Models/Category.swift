//
//  Category.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/15/24.
//

import Foundation
import SwiftyJSON

struct Category: Identifiable {
    let id: String
    let name: String
    let index: Int
    let type: String
    let isGenre: Bool
    let logoURL: URL?
    let bannerLogoURL: URL?
    let hasAccessibleInfo: Bool
    
    init(from json: JSON) throws {
        id = json["id"].stringValue
        name = json["name"].stringValue
        index = json["index"].intValue
        type = json["type"].stringValue
        isGenre = json["is_genre"].boolValue
        
        if let logoURLString = json["logo_url"].string {
            logoURL = URL(string: logoURLString)
        } else { logoURL = nil }
        if let bannerLogoURLString = json["banner_logo_url"].string {
            bannerLogoURL = URL(string: bannerLogoURLString)
        } else { bannerLogoURL = nil }
        
        hasAccessibleInfo = json["has_accessible_infos"].boolValue
    }
}
