//
//  Date+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/15/24.
//

import Foundation

extension Date {
    func formatted(_ string: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter.string(from: self)
    }
}
