//
//  minutesToHoursAndMinutes.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import Foundation

func minutesToHoursAndMinutes(_ minutes: Int) -> String {
    let hours = minutes / 60
    let minutes = minutes % 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    }
    
    return "\(minutes)m"
}
