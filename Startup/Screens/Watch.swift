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
    
    // Needs initialized
    let media: MediaViewModel
    
    @State private var season: Int?
    @State private var episode: Int?
    
    // Player state variables
    @State private var secureLink: String?
    @State private var player = VLCMediaPlayer()
    @State private var isPlaying = false
    @State private var mediaLength = VLCTime()
    @State private var time = VLCTime()
    @State private var timeRemaining: VLCTime?
    @State private var position: Float = 0.0
    @State private var chapterIndex: Int = 0
    
    // Addition state variables
    @State private var fullScreen = true
    @State private var showControls = false
    @State private var hoverControlsTimer: Timer?
    @FocusState private var isFocused: Bool
    
    
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
                    VLCPlayerRepresentable(
                        player: player,
                        url: url,
                        isPlaying: $isPlaying,
                        position: $position,
                        mediaLength: $mediaLength,
                        time: $time,
                        timeRemaining: $timeRemaining,
                        chapterIndex: $chapterIndex
                    )
                    .onAppear {
                        player.play()
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
                    .trackingMouse { location in
                        withAnimation { showControls = true }
                        NSCursor.unhide()
                        controlsTimerCountdown()
                    } onEntered: { location in
                        withAnimation { showControls = true }
                        NSCursor.unhide()
                        controlsTimerCountdown()
                    } onExited: { location in
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
        .onKeyPress(.space) {
            player.isPlaying ? player.pause(): player.play()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            player.jumpForward(10)
            return .handled
        }
        .onKeyPress(.leftArrow) {
            player.jumpBackward(10)
            return .handled
        }
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
    @ViewBuilder private func Controls(geometry: GeometryProxy) -> some View {
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
                // Scrubber
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Text(time.stringValue)
                        
                        Spacer()
                        
                        if let timeRemaining {
                            Text(timeRemaining.stringValue)
                        }
                    }
                    .padding(.bottom, -10)
                    .allowsHitTesting(false)
                    
                    Scrubber(value: $position, mediaLength: $mediaLength, player: player)
                        .frame(height: 40)
                }
                
                // Player controls
                HStack {
                    HStack(spacing: 16) {
                        PlayerButton {
                            Button {
                                player.isPlaying ? player.pause(): player.play()
                            } label: {
                                Label(isPlaying ? "Pause": "Play", systemImage: isPlaying ? "pause.fill": "play.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.largeTitle)
                            }
                        }
                        
                        PlayerButton {
                            Button {
                                player.jumpBackward(10)
                            } label: {
                                Label("Jump Forward", systemImage: "gobackward.10")
                                    .labelStyle(.iconOnly)
                                    .font(.largeTitle)
                            }
                        }
                        
                        PlayerButton {
                            Button {
                                player.jumpForward(10)
                            } label: {
                                Label("Jump Forward", systemImage: "goforward.10")
                                    .labelStyle(.iconOnly)
                                    .font(.largeTitle)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Text(media.value.title)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 16) {
                        Spacer()
                        
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
        .foregroundStyle(.white)
        .padding(16)
    }
    
    @ViewBuilder private func PlayerButton<Content: View>(_ content: @escaping () -> Content) -> some View {
        Hover { isHovering in
            content()
                .buttonStyle(.plain)
                .scaleEffect(isHovering ? 1.2: 1)
                .opacity(isHovering ? 0.5: 1)
        }
    }
}

// MARK: Private methods
extension Watch {
    private func controlsTimerCountdown() {
        hoverControlsTimer?.invalidate()
        hoverControlsTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { timer in
            DispatchQueue.main.async {
                withAnimation { self.showControls = false }
                NSCursor.hide()
            }
        }
    }
}

fileprivate struct Scrubber: View {
    @Binding var value: Float
    @Binding var mediaLength: VLCTime
    let player: VLCMediaPlayer
    
    @State private var isHovering = false
    @State private var mousePosition: CGFloat = .zero
    @State private var labelSize: CGSize = CGSize()
    
    var lineHeight: CGFloat {
        return isHovering ? 7: 3
    }
    
    let indicatorWidth: CGFloat = 11
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                Group {
                    Color("ScrubberBG")
                    Color("Netflix")
                        .frame(width: geometry.size.width * CGFloat(value))
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .zIndex(0)
                
                // Hover indicator
                if isHovering {
                    Color.white
                        .frame(width: 2, height: lineHeight)
                        .offset(x: mousePosition - 1)
                        .zIndex(1)
                    
                    Text(millisecondsToHoursMinutesAndSeconds(
                        CGFloat(mediaLength.intValue) *
                        (mousePosition / geometry.size.width)
                    ))
                    .shadow(radius: 1)
                    .shadow(radius: 1)
                    .shadow(radius: 1)
                    .shadow(radius: 1)
                    .shadow(radius: 1)
                    .dimensions($labelSize)
                    .offset(x: mousePosition > geometry.size.width / 2 ? (-labelSize.width + 12): -12)
                    .offset(x: mousePosition - 1)
                    .offset(y: -labelSize.height - 8)
                }
            }
            .frame(height: lineHeight)
            .offset(y: geometry.size.height / 2 - lineHeight / 2)
            .zIndex(0)
            
            Group {
                Circle().fill(Color("Netflix"))
                    .frame(width: indicatorWidth, height: 20)
            }
            .offset(y: geometry.size.height / 2 - 10)
            .offset(x: geometry.size.width * CGFloat(value) - indicatorWidth / 2)
            .zIndex(1)
            
            Rectangle().fill(.clear).frame(height: geometry.size.height)
                .contentShape(Rectangle())
                .trackingMouse { location in
                    mousePosition = location.x
                } onEntered: { location in
                    withAnimation { isHovering = true }
                } onExited: { location in
                    withAnimation { isHovering = false }
                }
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { tap in
                            // Jump to this part
                            let progress = Float(tap.location.x / geometry.size.width)
                            player.position = progress
                            value = progress
                        }
                )
                .zIndex(2)
        }
    }
}
