//
//  MediaCard.swift
//  Startup
//
//  Created by David Rozmajzl on 5/19/24.
//

import SwiftUI
import CachedAsyncImage

struct MediaCard: View {
    let media: MediaViewModel
    @Binding var selectedMedia: MediaViewModel?
    
    init(_ media: MediaViewModel, selected: Binding<MediaViewModel?>) {
        self.media = media
        _selectedMedia = selected
    }
    
    var body: some View {
        GeometryReader { geometry in
            HoverScale(scale: 1.05) {
                Button {
                    withAnimation { selectedMedia = media }
                } label: {
                    ZStack {
                        CachedAsyncImage(url: media.value.meta.poster, urlCache: .imageCache) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                        
                        if let seconds = media.value.history?.seconds,
                           let runtime = minutesToSeconds(media.value.meta.runtime) {
                            VStack {
                                Spacer()
                                
                                GeometryReader { geo in
                                    Group {
                                        Rectangle().fill(.regularMaterial)
                                        
                                        Color.accentColor
                                            .frame(width: geo.size.width * max(0.05, min(1, CGFloat(seconds) / CGFloat(runtime))))
                                    }
                                    .clipShape(Capsule())
                                }
                                .frame(height: geometry.size.height * 0.03)
                            }
                            .padding(geometry.size.width * 0.05)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(height: geometry.size.width * 1.5)
        }
    }
}
