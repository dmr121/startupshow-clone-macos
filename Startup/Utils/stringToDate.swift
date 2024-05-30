//
//  stringToDate.swift
//  Startup
//
//  Created by David Rozmajzl on 5/30/24.
//

import Foundation

func toDate(_ string: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: string)
}
