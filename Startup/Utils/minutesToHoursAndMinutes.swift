//
//  minutesToHoursAndMinutes.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import Foundation

func minutesToSeconds(_ minutes: String) -> Int? {
    let int = Int(minutes)
    return int != nil ? int! * 60: nil
}

func minutesToHoursAndMinutes(_ minutes: Int) -> String {
    let hours = minutes / 60
    let minutes = minutes % 60
    
    if hours > 0 {
        if minutes > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(hours)h"
    }
    
    return "\(minutes)m"
}

func millisecondsToHoursMinutesAndSeconds(_ milliseconds: CGFloat) -> String {
    let totalSeconds = Int(milliseconds) / 1000
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds / 60) % 60
    let seconds = totalSeconds % 60
    
    if hours > 0 {
        return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
}
