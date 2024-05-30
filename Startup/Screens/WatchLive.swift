//
//  WatchLive.swift
//  Startup
//
//  Created by David Rozmajzl on 5/30/24.
//

import SwiftUI
import AVFoundation
import AVKit

struct PlayerView: NSViewRepresentable {
    //    let player: AVPlayer
    let mediaURL: URL
    
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        
        let playerItem = AVPlayerItem(url: mediaURL)
        let pplayer = AVPlayer(playerItem: playerItem)
        
        playerView.player = pplayer
        pplayer.play()
        return playerView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        //        nsView.player = player
    }
}

struct WatchLive: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    
    // Needs initialized
    let channel: LiveTVChannelViewModel
    
    @State private var secureLink: String? = "https://169-150-236-55.servers.party:5052/live22/hyORAEe5WtHsLlgINVjRjg/216459/1717123779/3081467.m3u8"
    @State private var player = AVPlayer()
    @State private var fullScreen = true
    
    init(_ channel: LiveTVChannelViewModel) {
        self.channel = channel
    }
    
    var body: some View {
        ZStack {
            if let secureLink {
                // TODO: Can just use VLC player with some adjustments
                Text(secureLink)
                    .onTapGesture {
                        let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(secureLink, forType: .string)
                    }
//                PlayerView(mediaURL: URL(string: secureLink)!)
            }
        }
//        .task {
//            do {
//                secureLink = try await channel.getMediaURL()
//            } catch {
//                print("🚨 Error getting secure link: \(error.localizedDescription)")
//            }
//        }
    }
}
