//
//  User.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

import Foundation
import SwiftyJSON

struct User {
    let id: Int
    let display: Display
    let username: String
    let active: Bool
    let owner: Int
    let accountType: Int
    let accountName: String
    let geo: Geo
    let allowDownload: Bool
    
    init(from json: JSON) throws {
        id = json["data"]["id"].intValue
        display = try Display(from: json["data"]["display"].arrayValue)
        username = json["data"]["username"].stringValue
        active = json["data"]["active"].boolValue
        owner = json["data"]["owner"].intValue
        accountType = json["data"]["account_type"].intValue
        accountName = json["data"]["account_name"].stringValue
        geo = try Geo(from: json["data"]["geo"])
        allowDownload = json["data"]["allow_download"].boolValue
    }
}

extension User {
    struct Display {
        let username: String?
        let registeredDate: String?
        let expirationDate: String?
        let reseller: String?
        let resellerWebsiteURL: URL?
        let accountType: String?
        let country: String?
        
        init(from json: [JSON]) throws {
            let dictionary = json.reduce([String: String]()) { partialResult, object in
                var partial = partialResult
                for (key, value) in object {
                    partial[key] = value.stringValue
                }
                return partial
            }
            
            username = dictionary["Username"]
            registeredDate = dictionary["Registered Date"]
            expirationDate = dictionary["Expiration Date"]
            reseller = dictionary["Reseller"]
            
            let resellerWebsiteURLString = dictionary["Reseller Website"]
            resellerWebsiteURL = resellerWebsiteURLString != nil ? URL(string: resellerWebsiteURLString!): nil
            
            accountType = dictionary["Account Type"]
            country = dictionary["Country"]
        }
    }
    
    struct Geo {
        let ip: String
        let AS: String
        let country: String
        let countryName: String
        let cityName: String
        let timezone: String
        let latitude: String
        let longitude: String
        
        init(from json: JSON) throws {
            ip = json["ip"].stringValue
            AS = json["as"].stringValue
            country = json["country"].stringValue
            countryName = json["country_name"].stringValue
            cityName = json["city_name"].stringValue
            timezone = json["timezone"].stringValue
            latitude = json["latitude"].stringValue
            longitude = json["longitude"].stringValue
        }
    }
}
