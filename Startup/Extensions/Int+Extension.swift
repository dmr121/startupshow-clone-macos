//
//  Int+Extension.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import Foundation

extension Int {
    var abbr: String {
        let num = Double(self)
        let thousand = num / 1_000
        let million = num / 1_000_000
        let billion = num / 1_000_000_000
        
        if billion >= 1.0 {
            var string = String(format: "%.1fM", billion)
            if string.last == "0" {
                string.removeLast()
                string.removeLast()
            }
            return string
        } else if million >= 1.0 {
            var string = String(format: "%.1fM", million)
            if string.last == "0" {
                string.removeLast()
                string.removeLast()
            }
            return string
        } else if thousand >= 1.0 {
            var string = String(format: "%.1fK", thousand)
            if string.last == "0" {
                string.removeLast()
                string.removeLast()
            }
            return string
        } else {
            return String(format: "%.0f", num)
        }
    }
}
