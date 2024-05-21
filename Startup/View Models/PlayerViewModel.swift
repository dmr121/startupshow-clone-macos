//
//  PlayerViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/21/24.
//

import SwiftUI
import VLCKit
import Combine

@Observable class PlayerViewModel {
    // Player specific values
    var player = VLCMediaPlayer()
    var isPlaying = false
    var mediaLength = VLCTime()
    var time = VLCTime()
    var timeRemaining: VLCTime?
    var position: Float = 0.0
    var chapterIndex: Int = 0
    
    // View specific values
    var fullScreen = true
    var showControls = false
}

// MARK: Public methods
extension PlayerViewModel {
    func togglePlaying() {
        player.isPlaying ? player.pause(): player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func jumpForward(_ interval: Int32) {
        player.jumpForward(interval)
    }
    
    func jumpBackward(_ interval: Int32) {
        player.jumpBackward(interval)
    }
}
