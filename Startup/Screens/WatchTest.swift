////
////  WatchTest.swift
////  Startup
////
////  Created by David Rozmajzl on 5/20/24.
////
//
//import SwiftUI
//import VLCKit
//
//fileprivate func dismiss() {
//    print("DISMISSING")
//}
//
//struct WatchTest: View {
//    let mediaTitle = "Tile of Show"
//    
//    @State private var secureLink: String? = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
//    @State private var player = VLCMediaPlayer()
//    @State private var isPlaying = false
//    @State private var mediaLength = VLCTime()
//    @State private var time = VLCTime()
//    @State private var timeRemaining: VLCTime?
//    @State private var fullScreen = true
//    @State private var position: Float = 0.0
//    @State private var chapterIndex: Int = 0
//    
//    @FocusState private var isFocused: Bool
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                if let secureLink, let url = URL(string: secureLink) {
//                    VLCPlayerRepresentable(
//                        player: player,
//                        url: url,
//                        isPlaying: $isPlaying,
//                        position: $position,
//                        mediaLength: $mediaLength,
//                        time: $time,
//                        timeRemaining: $timeRemaining,
//                        chapterIndex: $chapterIndex
//                    )
//                    .onAppear {
//                        player.play()
//                    }
//                    
//                    Controls(geometry: geometry)
//                } else {
//                    ProgressView()
//                }
//            }
//            .frame(width: geometry.size.width, height: geometry.size.height)
//        }
//        .background(.black)
//        .toolbar(.hidden, for: .windowToolbar)
//        .monitorFullscreen(isFullscreen: $fullScreen)
//        .focused($isFocused)
//        .focusEffectDisabled()
//        .onKeyPress(.space) {
//            player.isPlaying ? player.pause(): player.play()
//            return .handled
//        }
//        .onKeyPress(.rightArrow) {
//            player.jumpForward(10)
//            return .handled
//        }
//        .onKeyPress(.leftArrow) {
//            player.jumpBackward(10)
//            return .handled
//        }
//        .onAppear {
//            isFocused = true
//        }
//        .onDisappear {
//            player.stop()
//        }
//    }
//}
//
//// MARK: Views
//extension WatchTest {
//    @ViewBuilder private func Controls(geometry: GeometryProxy) -> some View {
//        VStack {
//            // Back button
//            HStack {
//                PlayerButton {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Label("Go back", systemImage: "arrow.backward")
//                            .labelStyle(.iconOnly)
//                            .font(.largeTitle)
//                    }
//                }
//                
//                Spacer()
//            }
//            
//            Spacer()
//            
//            // Bottom controls
//            VStack {
//                // Scrubber
//                VStack(spacing: 0) {
//                    HStack(spacing: 16) {
//                        Text(time.stringValue)
//                        
//                        Spacer()
//                        
//                        if let timeRemaining {
//                            Text(timeRemaining.stringValue)
//                        }
//                    }
//                    .padding(.bottom, -10)
//                    .allowsHitTesting(false)
//                    
//                    Scrubber(value: $position, mediaLength: $mediaLength, player: player)
//                        .frame(height: 40)
//                }
//                
//                // Player controls
//                HStack {
//                    HStack(spacing: 16) {
//                        PlayerButton {
//                            Button {
//                                player.isPlaying ? player.pause(): player.play()
//                            } label: {
//                                Label(isPlaying ? "Pause": "Play", systemImage: isPlaying ? "pause.fill": "play.fill")
//                                    .labelStyle(.iconOnly)
//                                    .font(.largeTitle)
//                            }
//                        }
//                        
//                        PlayerButton {
//                            Button {
//                                player.jumpBackward(10)
//                            } label: {
//                                Label("Jump Forward", systemImage: "gobackward.10")
//                                    .labelStyle(.iconOnly)
//                                    .font(.largeTitle)
//                            }
//                        }
//                        
//                        PlayerButton {
//                            Button {
//                                player.jumpForward(10)
//                            } label: {
//                                Label("Jump Forward", systemImage: "goforward.10")
//                                    .labelStyle(.iconOnly)
//                                    .font(.largeTitle)
//                            }
//                        }
//                        
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity)
//                    
//                    
//                    Text(mediaTitle)
//                        .multilineTextAlignment(.center)
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                    
//                    HStack(spacing: 16) {
//                        Spacer()
//                        
//                        PlayerButton {
//                            Button(action: toggleFullScreen) {
//                                Label("Fullscreen", systemImage: fullScreen ? "rectangle.center.inset.filled":  "rectangle.inset.filled")
//                                    .labelStyle(.iconOnly)
//                                    .font(.largeTitle)
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//        }
//        .foregroundStyle(.white)
//        .padding(16)
//    }
//    
//    @ViewBuilder private func PlayerButton<Content: View>(_ content: @escaping () -> Content) -> some View {
//        Hover { isHovering in
//            content()
//                .buttonStyle(.plain)
//                .scaleEffect(isHovering ? 1.2: 1)
//                .opacity(isHovering ? 0.5: 1)
//        }
//    }
//}
//
//// MARK: Private methods
//extension WatchTest {
//    
//}
//
//fileprivate struct Scrubber: View {
//    @Binding var value: Float
//    @Binding var mediaLength: VLCTime
//    let player: VLCMediaPlayer
//    
//    @State private var isHovering = false
//    @State private var mousePosition: CGFloat = .zero
//    @State private var labelSize: CGSize = CGSize()
//    
//    var lineHeight: CGFloat {
//        return isHovering ? 7: 3
//    }
//    
//    let indicatorWidth: CGFloat = 11
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Group {
//                Group {
//                    Color("ScrubberBG")
//                    Color("Netflix")
//                        .frame(width: geometry.size.width * CGFloat(value))
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 2))
//                .zIndex(0)
//                
//                // Hover indicator
//                if isHovering {
//                    Color.white
//                        .frame(width: 2, height: lineHeight)
//                        .offset(x: mousePosition - 1)
//                        .zIndex(1)
//                    
//                    Text(millisecondsToHoursMinutesAndSeconds(
//                        CGFloat(mediaLength.intValue) *
//                        (mousePosition / geometry.size.width)
//                    ))
//                    .shadow(radius: 1)
//                    .shadow(radius: 1)
//                    .shadow(radius: 1)
//                    .shadow(radius: 1)
//                    .shadow(radius: 1)
//                    .dimensions($labelSize)
//                    .offset(x: mousePosition > geometry.size.width / 2 ? (-labelSize.width + 12): -12)
//                    .offset(x: mousePosition - 1)
//                    .offset(y: -labelSize.height - 8)
//                }
//            }
//            .frame(height: lineHeight)
//            .offset(y: geometry.size.height / 2 - lineHeight / 2)
//            .zIndex(0)
//            
//            Group {
//                Circle().fill(Color("Netflix"))
//                    .frame(width: indicatorWidth, height: 20)
//            }
//            .offset(y: geometry.size.height / 2 - 10)
//            .offset(x: geometry.size.width * CGFloat(value) - indicatorWidth / 2)
//            .zIndex(1)
//            
//            Rectangle().fill(.clear).frame(height: geometry.size.height)
//                .contentShape(Rectangle())
//                .trackingMouse { location in
//                    mousePosition = location.x
//                } onEntered: { location in
//                    withAnimation { isHovering = true }
//                } onExited: { location in
//                    withAnimation { isHovering = false }
//                }
//                .simultaneousGesture(
//                    SpatialTapGesture()
//                        .onEnded { tap in
//                            // Jump to this part
//                            let progress = Float(tap.location.x / geometry.size.width)
//                            player.position = progress
//                            value = progress
//                        }
//                )
//                .zIndex(2)
//        }
//    }
//}
