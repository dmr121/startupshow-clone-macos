//
//  VLC.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import Foundation

func openVLC() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["/Applications/VLC.app"]
    
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        print("An error occurred: \(error)")
    }
}
