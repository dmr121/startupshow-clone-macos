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

// This actually works
fileprivate let options: [String] = [
    "--freetype-fontsize=64",
]

struct Watch: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    
    // Needs initialized
    let media: MediaViewModel
    
    @State private var season: Int?
    @State private var episode: Int?
    
    let initialPosition: Float
    
    // Player state variables
    @State private var secureLink: String?
    @State private var player = VLCMediaPlayer(options: options)!
    @State private var isPlaying = false
    @State private var mediaLength = VLCTime()
    @State private var time = VLCTime()
    @State private var timeRemaining: VLCTime?
    @State private var position: Float = .zero
    @State private var volume: Float = 1
    @State private var chapterIndex: Int = 0
    @State private var subtitles = [Subtitles]()
    @State private var currentSubtitleIndex: Int?
    
    // Addition state variables
    @State private var fullScreen = true
    @State private var showControls = false
    @State private var hasLoadedInitially = false
    @State private var hoverControlsTimer: Timer?
    @FocusState private var isFocused: Bool
    
    
    init(_ media: MediaViewModel) {
        self.media = media
        
        switch media.type {
        case .tv(let season, let episode, let duration):
            _season = State(initialValue: season)
            _episode = State(initialValue: episode)
            
            if let data = media.value.history?.data {
                let history = data.first { hist in
                    return hist.episode == episode && hist.season == season
                }
                
                if let seconds = history?.seconds {
                    // Episode duration is stored in seconds
                    let durationSeconds = duration * 60
                    self.initialPosition = Float(seconds) / Float(durationSeconds)
                } else {
                    self.initialPosition = .zero
                }
            } else {
                self.initialPosition = .zero
            }
        default:
            _season = State(initialValue: nil)
            _episode = State(initialValue: nil)
            
            if let seconds = media.value.history?.seconds,
               let runtime = minutesToSeconds(media.value.meta.runtime) {
                self.initialPosition = Float(seconds) / Float(runtime)
            } else {
                self.initialPosition = .zero
            }
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
                        isFocused = true
                        player.position = initialPosition
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
        .onKeyPress(.space) {
            togglePause()
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                hasLoadedInitially = true
            }
        }
        .onDisappear {
            player.stop()
            hoverControlsTimer?.invalidate()
            NSCursor.unhide()
            
            guard hasLoadedInitially else { return }
            markPosition()
        }
        .task {
            do {
                if let season, let episode {
                    subtitles = try await media.getSubtitles(profile: auth.profile, season: season, episode: episode)
                    secureLink = try await media.getMediaURL(profile: auth.profile, season: season, episode: episode)
                } else {
                    subtitles = try await media.getSubtitles(profile: auth.profile)
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
        ZStack {
            Rectangle().fill(.clear)
                .frame(height: geometry.size.height)
                .contentShape(Rectangle())
                .onTapGesture {
                    togglePause()
                }
            
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
                                    controlsTimerCountdown()
                                    togglePause()
                                } label: {
                                    Label(isPlaying ? "Pause": "Play", systemImage: isPlaying ? "pause.fill": "play.fill")
                                        .labelStyle(.iconOnly)
                                        .font(.largeTitle)
                                }
                            }
                            
                            PlayerButton {
                                Button {
                                    controlsTimerCountdown()
                                    player.jumpBackward(10)
                                } label: {
                                    Label("Jump Forward", systemImage: "gobackward.10")
                                        .labelStyle(.iconOnly)
                                        .font(.largeTitle)
                                }
                            }
                            
                            PlayerButton {
                                Button {
                                    controlsTimerCountdown()
                                    player.jumpForward(10)
                                } label: {
                                    Label("Jump Forward", systemImage: "goforward.10")
                                        .labelStyle(.iconOnly)
                                        .font(.largeTitle)
                                }
                            }
                            
                            Volume(value: $volume, player: player, controlsTimerCountdown: controlsTimerCountdown)
                                .frame(maxWidth: 100)
                                .frame(height: 28)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        Text(media.value.title)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 16) {
                            Spacer()
                            
                            
                            // TODO: Be able to adjust subtitle speed
                            if player.videoSubTitlesNames.count > 0 {
                                SubtitlesMenu()
                            } else if let urls = subtitles.first?.urls {
                                SubtitlesMenu(urls: urls)
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
extension Watch {
    private func markPosition() {
        Task {
            do {
                let seconds = Int(time.intValue) / 1000
                var message: String?
                
                if let season, let episode {
                    message = try await media.markPosition(seconds, profile: auth.profile, season: season, episode: episode)
                } else {
                    message = try await media.markPosition(seconds, profile: auth.profile)
                }
                
                guard let message else { return }
                print(message)
            } catch {
                print("🚨 Error setting position: \(error.localizedDescription)")
            }
        }
    }
    
    private func togglePause() {
        isPlaying ? player.pause(): player.play()
    }
    
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

struct Volume: View {
    @Binding var value: Float
    let player: VLCMediaPlayer
    let controlsTimerCountdown: (_: Bool) -> ()
    
    @State private var isDragging = false
    
    let lineHeight: CGFloat = 4
    let indicatorWidth: CGFloat = 11
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                Group {
                    Color("ScrubberBG")
                    Color.white
                        .frame(width: geometry.size.width * CGFloat(value))
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .zIndex(0)
            }
            .frame(height: lineHeight)
            .offset(y: geometry.size.height / 2 - lineHeight / 2)
            .zIndex(0)
            
            Group {
                Circle().fill(.white)
                    .frame(width: indicatorWidth, height: 20)
            }
            .offset(y: geometry.size.height / 2 - 10)
            .offset(x: geometry.size.width * CGFloat(value) - indicatorWidth / 2)
            .zIndex(1)
            
            Rectangle().fill(.clear).frame(height: geometry.size.height)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            onDragChanged(drag.location.x, geometry: geometry)
                            controlsTimerCountdown(true)
                        }
                )
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { tap in
                            onDragChanged(tap.location.x, geometry: geometry)
                            controlsTimerCountdown(true)
                        }
                )
                .zIndex(2)
        }
    }
    
    func onDragChanged(_ location: Double, geometry: GeometryProxy) {
        let progress = Float(location / geometry.size.width)
        player.audio.volume = Int32(progress * 100)
        value = max(0, min(1, progress))
    }
}
