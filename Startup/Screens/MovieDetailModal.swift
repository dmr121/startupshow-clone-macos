//
//  MovieDetailModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import CachedAsyncImage

struct MovieDetailModal: View {
    @Environment(\.dismiss) private var dismiss
    
    let movie: Movie
    
    init(_ movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    CachedAsyncImage(url: movie.meta.fanart, urlCache: .imageCache) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.85)
                    .clipped()
                    .background(.secondary.opacity(0.2))
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            Hover { isHovering in
                                Button {
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle().fill(.black).opacity(isHovering ? 0.65: 0.35)
                                        
                                        Image(systemName: "xmark")
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white.opacity(isHovering ? 0.75: 0.6))
                                    }
                                    .frame(width: 32, height: 32)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(8)
                }
                
                VStack(spacing: 0) {
                    LinearGradient(colors: [Color.background, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 200)
                    
                    VStack {
                        ForEach(0..<200) { _ in
                            Text(movie.title)
                        }
                    }
                    .padding(.top, -100)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, -200)
                
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.background)
    }
}
