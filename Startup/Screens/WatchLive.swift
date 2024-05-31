//
//  WatchLive.swift
//  Startup
//
//  Created by David Rozmajzl on 5/30/24.
//

import SwiftUI
import CachedAsyncImage
import Foundation
import VLCKit
import Lottie

// This actually works
fileprivate let options: [String] = [
    "--freetype-fontsize=40",
]

struct WatchLive: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    
    // Needs initialized
    let channel: LiveTVChannelViewModel
    
    // Player state variables
    @State private var secureLink: String?
    @State private var player = VLCMediaPlayer(options: options)!
    @State private var isPlaying = false
    @State private var mediaLength = VLCTime()
    @State private var time = VLCTime()
    @State private var timeRemaining: VLCTime?
    @State private var position: Float = .zero
    @State private var volume: Float = 1
    @State private var subtitles = [Subtitles]()
    @State private var currentSubtitleIndex: Int?
    
    // Addition state variables
    @State private var fullScreen = true
    @State private var showControls = false
    @State private var hoverControlsTimer: Timer?
    @FocusState private var isFocused: Bool
    
    @State private var epgs = [EPG]()
    
    init(_ channel: LiveTVChannelViewModel) {
        self.channel = channel
    }
    
    private var currentShow: EPG? {
        return epgs.first(where: { Date() >= $0.start && Date() <= $0.stop })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let secureLink, let url = URL(string: secureLink) {
                    VLCPlayerRepresentable(
                        player: player,
                        url: url,
                        isPlaying: $isPlaying,
                        position: $position,
                        mediaLength: $mediaLength,
                        time: $time,
                        timeRemaining: $timeRemaining,
                        chapterIndex: .constant(0)
                    )
                    .onAppear {
                        isFocused = true
                    }
                    
                    Controls(geometry: geometry)
                        .opacity(showControls || !isPlaying ? 1: 0)
                    
                } else {
                    ProgressView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                GeometryReader { _ in }
                    .trackingMouse { _ in
                        controlsTimerCountdown()
                    } onEntered: { _ in
                        controlsTimerCountdown()
                    } onExited: { _ in
                        withAnimation { showControls = false }
                    }
            }
        }
        .background(.black)
        .toolbar(.hidden, for: .windowToolbar)
        .monitorFullscreen(isFullscreen: $fullScreen)
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onDisappear {
            player.stop()
            hoverControlsTimer?.invalidate()
            NSCursor.unhide()
        }
        .task {
            do {
                secureLink = try await channel.getMediaURL()
            } catch {
                print("🚨 Error getting secure link: \(error.localizedDescription)")
            }
        }
        .task {
            do {
                self.epgs = try await channel.getEpisodeGuide()
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Views
extension WatchLive {
    @ViewBuilder private func Controls(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack {
                // Back button
                HStack {
                    PlayerButton {
                        Button {
                            dismiss()
                        } label: {
                            Label("Go back", systemImage: "arrow.backward")
                                .labelStyle(.iconOnly)
                                .font(.largeTitle)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Bottom controls
                VStack {
                    // Player controls
                    HStack {
                        HStack(spacing: 16) {
                            LottieView {
                                LottieAnimation.named("live_lottie_animation")?.animationSource
                            }
                            .looping()
                            .frame(width: 25)
                            
                            Volume(value: $volume, player: player, controlsTimerCountdown: controlsTimerCountdown)
                                .frame(maxWidth: 100)
                                .frame(height: 28)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        VStack {
                            Text(channel.value.name)
                                .font(.headline)
                            
                            if let currentShow {
                                Text(currentShow.title)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 16) {
                            Spacer()
                            
                            if player.videoSubTitlesNames.count > 0 {
                                SubtitlesMenu()
                            }
                            
                            PlayerButton {
                                Button(action: toggleFullScreen) {
                                    Label("Fullscreen", systemImage: fullScreen ? "rectangle.center.inset.filled":  "rectangle.inset.filled")
                                        .labelStyle(.iconOnly)
                                        .font(.largeTitle)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(16)
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder private func PlayerButton<Content: View>(_ content: @escaping () -> Content) -> some View {
        Hover { isHovering in
            content()
                .buttonStyle(.plain)
                .scaleEffect(isHovering ? 1.2: 1)
                .opacity(isHovering ? 0.5: 1)
        }
    }
    
    @ViewBuilder private func SubtitlesMenu() -> some View {
        PlayerButton {
            Menu {
                Button {
                    player.currentVideoSubTitleIndex = -1
                    currentSubtitleIndex = nil
                } label: {
                    if currentSubtitleIndex == nil {
                        Image(systemName: "checkmark")
                            .resizable()
                    }
                    
                    Text("Turn Off Subtitles")
                }
                Divider()
                
                ForEach(Array(player.videoSubTitlesNames.enumerated()), id: \.offset) { index, name in
                    if let adjustedIndex = player.videoSubTitlesIndexes[index] as? Int,
                       adjustedIndex != -1 {
                        Button {
                            currentSubtitleIndex = adjustedIndex
                            player.currentVideoSubTitleIndex = Int32(adjustedIndex)
                        } label: {
                            if currentSubtitleIndex == adjustedIndex {
                                Image(systemName: "checkmark")
                                    .resizable()
                            }
                            Text("\(name)")
                        }
                        Divider()
                    }
                }
            } label: {
                Label("Subtitles", systemImage: "captions.bubble.fill")
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
            }
            .scaleEffect(0.85)
        }
    }
    
    @ViewBuilder private func SubtitlesMenu(urls: [String: URL]) -> some View {
        PlayerButton {
            Menu {
                Button {
                    player.currentVideoSubTitleIndex = -1
                    currentSubtitleIndex = nil
                } label: {
                    if currentSubtitleIndex == nil {
                        Image(systemName: "checkmark")
                            .resizable()
                    }
                    
                    Text("Turn Off Subtitles")
                }
                Divider()
                
                ForEach(Array(urls.keys), id: \.self) { key in
                    if let url = urls[key] {
                        let index = urls.values.distance(from: urls.values.startIndex, to: urls.values.firstIndex(of: url)!)
                        Button {
                            player.addPlaybackSlave(urls[key], type: .subtitle, enforce: true)
                            currentSubtitleIndex = index
                        } label: {
                            if currentSubtitleIndex == index {
                                Image(systemName: "checkmark")
                                    .resizable()
                            }
                            
                            Text(key)
                        }
                        Divider()
                    }
                }
            } label: {
                Label("Subtitles", systemImage: "captions.bubble.fill")
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
            }
            .scaleEffect(0.85)
        }
    }
}

// MARK: Private methods
extension WatchLive {
    private func controlsTimerCountdown(restart: Bool = true) {
        withAnimation { showControls = true }
        NSCursor.unhide()
        hoverControlsTimer?.invalidate()
        
        guard restart else { return }
        
        hoverControlsTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { timer in
            DispatchQueue.main.async {
                withAnimation { self.showControls = false }
                
                if !fullScreen { return }
                NSCursor.hide()
            }
        }
    }
}
