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
                    CachedAsyncImage(url: media.value.meta.poster, urlCache: .imageCache) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(0.6)
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
