//
//  LoginResponse.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

import Foundation
import SwiftyJSON

struct LoginResponse {
    let token: String
    let tokenType: String
    let expiresAt: Date
    let service: Service
    
    init(from json: JSON) throws {
        token = json["data"]["token"].stringValue
        tokenType = json["data"]["token_type"].stringValue
        
        let expiresAtString = json["data"]["expires_at"].stringValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.dateFormat
        expiresAt = dateFormatter.date(from: expiresAtString)!
        
        service = try Service(from: json["data"]["service"])
    }
}

extension LoginResponse {
    struct Service {
        let name: String
        let website: URL?
        let logoSmallURL: URL?
        let logoLargeURL: URL?
        let logo40PxURL: URL?
        let color: String?
        let movies: Bool
        let liveTV: Bool
        let tvShows: Bool
        let tvGuide: Bool
        let adults: Bool
        
        init(from json: JSON) throws {
            name = json["name"].stringValue
            website = json["website"].url
            logoSmallURL = json["logo_small"].url
            logoLargeURL = json["logo_large"].url
            logo40PxURL = json["logo_40px"].url
            color = json["color"].string
            movies = json["movies"].boolValue
            liveTV = json["livetv"].boolValue
            tvShows = json["tvshows"].boolValue
            tvGuide = json["tvguide"].boolValue
            adults = json["adults"].boolValue
        }
    }
}
