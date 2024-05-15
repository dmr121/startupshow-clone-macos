//
//  URLCache+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/17/24.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
