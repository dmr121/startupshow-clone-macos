//
//  fullScreen.swift
//  Startup
//
//  Created by David Rozmajzl on 5/18/24.
//

import SwiftUI

func toggleFullScreen() {
    let window = NSApp.windows.first { $0.isKeyWindow }
    window?.toggleFullScreen(nil)
}
