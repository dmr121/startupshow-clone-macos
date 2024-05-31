//
//  LiveTVChannelTile.swift
//  Startup
//
//  Created by David Rozmajzl on 5/31/24.
//

import SwiftUI
import CachedAsyncImage

struct LiveTVChannelTile: View {
    @Environment(Navigation.self) private var navigation
    
    let channel: LiveTVChannelViewModel
    @Binding private var selectedChannel: LiveTVChannelViewModel?
    
    init(_ channel: LiveTVChannelViewModel, selectedChannel: Binding<LiveTVChannelViewModel?>) {
        self.channel = channel
        _selectedChannel = selectedChannel
    }
    
    var body: some View {
        GeometryReader { geometry in
            Hover { isHovering in
                Button {
                    selectedChannel = channel
                } label: {
                    ZStack {
                        isHovering ? Color.backgroundLighter: .background
                        
                        VStack {
                            CachedAsyncImage(url: channel.value.logo, urlCache: .imageCache) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "tv")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: geometry.size.width * 0.4444, height: geometry.size.width * 0.4444)
                            
                            Text(channel.value.name)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                if isHovering {
                                    Hover { buttonHovering in
                                        Button {
                                            navigation.mediaPaths.append(channel)
                                        } label: {
                                            Label("Watch", systemImage: "play.fill")
                                                .labelStyle(.iconOnly)
                                                .font(.system(size: 18))
                                                .frame(width: 30, height: 30)
                                                .background(buttonHovering ? .accent: .white)
                                                .foregroundStyle(buttonHovering ? .white: .black)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .scaleEffect(buttonHovering ? 1.12: 1, anchor: .bottomTrailing)
                                    }
                                    .transition(.scale(scale: 0.5, anchor: .bottomTrailing).combined(with: .opacity))
                                }
                            }
                        }
                        .padding(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
    }
}
