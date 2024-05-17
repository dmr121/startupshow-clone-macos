//
//  Category.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/15/24.
//

import Foundation
import SwiftyJSON

struct Category: Identifiable, Hashable {
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
        logoURL = json["logo_url"].url
        bannerLogoURL = json["banner_logo_url"].url
        hasAccessibleInfo = json["has_accessible_infos"].boolValue
    }
}
