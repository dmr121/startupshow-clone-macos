//
//  Array+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/15/24.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array: Identifiable where Element: Hashable {
    public var id: Int { self.hashValue }
}
