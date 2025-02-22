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
    @Binding private var isPlaying: Bool
    @Binding private var position: Float
    @Binding private var mediaLength: VLCTime
    @Binding private var time: VLCTime
    @Binding private var timeRemaining: VLCTime?
    @Binding private var chapterIndex: Int
    //    @Binding private var chapterIndex: Int
    
    init(player: VLCMediaPlayer, url: URL, isPlaying: Binding<Bool>, position: Binding<Float>, mediaLength: Binding<VLCTime>, time: Binding<VLCTime>, timeRemaining: Binding<VLCTime?>, chapterIndex: Binding<Int>) {
        self.player = player
        self.mediaURL = url
        _isPlaying = isPlaying
        _position = position
        _mediaLength = mediaLength
        _time = time
        _timeRemaining = timeRemaining
        _chapterIndex = chapterIndex
    }
    
    func makeNSView(context: Context) -> VLCVideoView {
        let view = VLCVideoView()
        
        player.drawable = view
        
        let media = VLCMedia(url: mediaURL)
        media.addOptions([
            "sub-filter": "marq",  // Example: Using a marquee filter for subtitles
            "freetype-rel-fontsize": "5",  // Relative font size
            "freetype-color": "16711680",  // Color in decimal RGB (white in this case)
            "freetype-background-color": "4278190080"  // Background color in decimal RGBA (semi-transparent black)
        ])
        setenv("VLC_FREETYPE_FONT_SIZE", "4", 1)
        
        player.media = media
        player.position = position
        player.delegate = context.coordinator
        
        player.play()
        
        return view
    }
    
    func updateNSView(_ nsView: VLCVideoView, context: Context) {
        context.coordinator.representable = self
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(representable: self)
    }
}

extension VLCPlayerRepresentable {
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
            representable.timeRemaining = player.remainingTime
            representable.time = player.time
            representable.mediaLength = player.media.length
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
}
