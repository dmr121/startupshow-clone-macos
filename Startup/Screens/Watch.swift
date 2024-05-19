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
    
    let movie: MovieViewModel
    
    @State private var secureLink: String?
    //    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    @State private var player = VLCMediaPlayer()
    @State private var isPlaying = false
    @State private var position: Float = 0.0
    @State private var chapterIndex: Int = 0
    
    init(_ movie: MovieViewModel) {
        self.movie = movie
    }
    
    var body: some View {
        Hover { isHovering in
            GeometryReader { geometry in
                ZStack {
                    if let secureLink, let url = URL(string: secureLink) {
                        VLCPlayerRepresentable(player: player, url: url, isPlaying: $isPlaying, position: $position, chapterIndex: $chapterIndex)
                            .onAppear {
                                player.play()
                            }
                        
                        Controls()
                            .opacity(isHovering ? 1: 0)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .background(.black)
        .toolbar(.hidden, for: .windowToolbar)
        .onDisappear {
            player.stop()
        }
        .task {
            do {
                secureLink = try await movie.getMovieURL(profile: auth.profile)
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
                Text(movie.value.title)
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
