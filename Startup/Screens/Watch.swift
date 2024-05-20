//
//  Watch.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import SwiftUI
import CachedAsyncImage
import Foundation
import VLCKit

struct Watch: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    
    let media: MediaViewModel
    
    @State private var season: Int?
    @State private var episode: Int?
    
    @State private var secureLink: String?
    @State private var player = VLCMediaPlayer()
    @State private var isPlaying = false
    @State private var position: Float = 0.0
    @State private var chapterIndex: Int = 0
    
    init(_ media: MediaViewModel) {
        self.media = media
        
        switch media.type {
        case .tv(let season, let episode):
            _season = State(initialValue: season)
            _episode = State(initialValue: episode)
        default:
            _season = State(initialValue: nil)
            _episode = State(initialValue: nil)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let secureLink, let url = URL(string: secureLink) {
                    VLCPlayerRepresentable(player: player, url: url, isPlaying: $isPlaying, position: $position, chapterIndex: $chapterIndex)
                        .onAppear {
                            player.play()
                        }
                    
                    Controls()
                } else {
                    ProgressView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(.black)
        .toolbar(.hidden, for: .windowToolbar)
        .onDisappear {
            player.stop()
        }
        .task {
            do {
                if let season, let episode {
                    secureLink = try await media.getMediaURL(profile: auth.profile, season: season, episode: episode)
                } else {
                    secureLink = try await media.getMediaURL(profile: auth.profile)
                }
            } catch {
                print("🚨 Error getting secure link: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Views
extension Watch {
    @ViewBuilder private func Controls() -> some View {
        VStack {
            HStack {
                Hover { isHovering in
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(isHovering ? 0.75: 0.6))
                            .padding(7)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isHovering ? 1.05: 1)
                }
                
                Text(media.value.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        player.isPlaying ? player.pause(): player.play()
                    } label: {
                        Label(isPlaying ? "Pause": "Play", systemImage: isPlaying ? "pause": "play")
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    }
                    .buttonStyle(.plain)
                    
                    GeometryReader { geometry in
                        Color.red.frame(width: geometry.size.width * CGFloat(position))
                            .clipShape(Capsule())
                    }
                    .frame(height: 10)
                    
                    Button {
                        let pos = Float.random(in: 0.0...1.0)
                        player.position = pos
                    } label: {
                        Label("Skip", systemImage: "figure.mixed.cardio")
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: toggleFullScreen) {
                        Label("Fullscreen", systemImage: "rectangle.expand.vertical")
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(16)
    }
}

// MARK: Private methods
extension Watch {
    
}
