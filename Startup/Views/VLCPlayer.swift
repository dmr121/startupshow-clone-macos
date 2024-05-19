//
//  VLCPlayer.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import Foundation
import AppKit
import SwiftUI
import VLCKit

struct VLCPlayerRepresentable: NSViewRepresentable {
    let player: VLCMediaPlayer
    let mediaURL: URL
    @Binding var isPlaying: Bool
    @Binding var position: Float
    @Binding var chapterIndex: Int
    
    init(player: VLCMediaPlayer, url: URL, isPlaying: Binding<Bool>, position: Binding<Float>, chapterIndex: Binding<Int>) {
        self.player = player
        self.mediaURL = url
        _isPlaying = isPlaying
        _position = position
        _chapterIndex = chapterIndex
    }
    
    func makeNSView(context: Context) -> VLCVideoView {
        let view = VLCVideoView()
        player.drawable = view
        player.media = VLCMedia(url: mediaURL)
        player.delegate = context.coordinator
        return view
    }
    
    func updateNSView(_ nsView: VLCVideoView, context: Context) {
        context.coordinator.representable = self
        // Do something when position changes
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(representable: self)
    }
}

class Coordinator: NSObject, VLCMediaPlayerDelegate { //, maybe delegate
    var representable: VLCPlayerRepresentable
    
    init(representable: VLCPlayerRepresentable) {
        self.representable = representable
    }
    
    func mediaPlayerStateChanged(_ notification: Notification) {
        guard let player = notification.object as? VLCMediaPlayer else { return }
        
        switch player.state {
        case .playing:
            representable.isPlaying = true
        case .ended, .paused, .stopped:
            representable.isPlaying = false
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ notification: Notification!) {
        guard let player = notification.object as? VLCMediaPlayer else { return }
        representable.isPlaying = player.isPlaying
        representable.position = player.position
    }
    
    func mediaPlayerChapterChanged(_ notification: Notification!) {
        guard let player = notification.object as? VLCMediaPlayer else { return }
        representable.chapterIndex = Int(player.currentChapterIndex)
    }
    
    func mediaPlayerLoudnessChanged(_ notification: Notification!) {
        guard let player = notification.object as? VLCMediaPlayer else { return }
        // player.audio.volume
    }
}
