//
//  EPG.swift
//  Startup
//
//  Created by David Rozmajzl on 5/27/24.
//

import Foundation
import SwiftyJSON

struct EPG: Identifiable, Equatable, Hashable {
    let start: Date
    let stop: Date
    let title: String
    let desc: String?
    
    init(from json: JSON) throws {
        let dateFormatter = DateFormatter()
        let startString = json["start"].stringValue
        dateFormatter.dateFormat = "yyyyMMddHHmmss Z"
        start = dateFormatter.date(from: startString)!
        
        let stopString = json["stop"].stringValue
        dateFormatter.dateFormat = "yyyyMMddHHmmss Z"
        stop = dateFormatter.date(from: stopString)!
        
        title = json["title"].stringValue
        desc = json["desc"].string
    }
    
    var id: String {
        let s = String(describing: start.formatted("yyyyMMddHHmmss Z"))
        let st = String(describing: stop.formatted("yyyyMMddHHmmss Z"))
        let d = String(describing: desc)
        return "\(s)\(st)\(title)\(d)"
    }
    
    static func == (lhs: EPG, rhs: EPG) -> Bool {
        lhs.id == rhs.id
    }
}
