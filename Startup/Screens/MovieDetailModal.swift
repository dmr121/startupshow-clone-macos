//
//  MovieDetailModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import CachedAsyncImage
import Foundation

struct MovieDetailModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    @Environment(CategoriesViewModel.self) private var categoriesViewModel
    
    let movie: Movie
    
    @State private var secureLink: String?
    @State private var pre = false
    
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
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                    .clipped()
                    .background(.secondary.opacity(0.2))
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .black, .clear]), startPoint: .top, endPoint: .bottom))
                    
                    // Dismiss button
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
                                        
                                        if isHovering {
                                            Circle().stroke(.white.opacity(0.3), lineWidth: 1)
                                        }
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
                
                // Details
                VStack(alignment: .leading, spacing: 0) {
                    LinearGradient(colors: [Color.background, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(movie.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Actions
                        HStack(spacing: 20) {
                            Hover{ isHovering in
                                Button(action: getSecureLink) {
                                    HStack {
                                        Label("Watch", systemImage: "eye.fill")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.black)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 18)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .scaleEffect(isHovering ? 1.05: 1, anchor: .bottomLeading)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack(spacing: 15) {
                                if let trailerURL = movie.meta.trailer {
                                    Hover { isHovering in
                                        Link(destination: trailerURL) {
                                            Label("Trailer", systemImage: "movieclapper.fill")
                                                .font(.system(size: 13))
                                                .labelStyle(.iconOnly)
                                                .frame(width: 34, height: 34)
                                                .background(
                                                    Group {
                                                        if isHovering {
                                                            Rectangle().fill(.regularMaterial)
                                                        } else {
                                                            Color.clear
                                                        }
                                                    }
                                                )
                                                .clipShape(Circle())
                                                .blendMode(.screen)
                                        }
                                        .buttonStyle(.plain)
                                        .scaleEffect(isHovering ? 1.05: 1)
                                    }
                                }
                                
                                Hover { isHovering in
                                    Button(action: {
                                        openVLC()
                                    }) {
                                        Label("Favorite", systemImage: "star")
                                            .font(.system(size: 16))
                                            .labelStyle(.iconOnly)
                                            .frame(width: 34, height: 34)
                                            .background(
                                                Group {
                                                    if isHovering {
                                                        Rectangle().fill(.regularMaterial)
                                                    } else {
                                                        Color.clear
                                                    }
                                                }
                                            )
                                            .clipShape(Circle())
                                            .blendMode(.screen)
                                    }
                                    .buttonStyle(.plain)
                                    .scaleEffect(isHovering ? 1.05: 1)
                                }
                            }
                        }
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack(spacing: 16) {
                                    // Released Year
                                    Text(movie.meta.year)
                                    
                                    // IMDB Rank
                                    HStack(spacing: 4) {
                                        Image("IMDB")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 27)
                                            .background(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                        
                                        Text(String(format: "%.1f", movie.meta.rank))
                                    }
                                    
                                    // Runtime
                                    if let minutes = Int(movie.meta.runtime) {
                                        Text(minutesToHoursAndMinutes(minutes))
                                    }
                                }
                                .foregroundStyle(.secondary)
                                
                                HStack(spacing: 16) {
                                    // MPPA Rating
                                    Text(movie.meta.mppa)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 1.5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 1)
                                                .stroke(.secondary)
                                        }
                                    
                                    // Genres
                                    Text(movie.meta.genres)
                                }
                                
                                Text(movie.meta.plot)
                                    .lineSpacing(6)
                                    .padding(.top)
                            }
                            .frame(width: geometry.size.width * 0.6)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Group {
                                    Text("Cast: ")
                                        .foregroundStyle(.secondary.opacity(0.6)) +
                                    Text(movie.meta.cast)
                                }
                                .lineSpacing(4)
                                
                                Group {
                                    Text("Director: ")
                                        .foregroundStyle(.secondary.opacity(0.6)) +
                                    Text(movie.meta.director)
                                }
                                .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 28)
                    }
                    .padding(.top, -140)
                    .padding(24)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, -200)
                
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.background)
        .sheet(isPresented: $pre, content: {
            MovieDetailModal(movie)
                .frame(minWidth: 750, minHeight: 533)
                .frame(maxWidth: 1000, maxHeight: 710)
        })
    }
}

// MARK: Private methods
extension MovieDetailModal {
    private func getSecureLink() {
        Task {
            do {
                secureLink = try await categoriesViewModel.getMovieURL(withId: movie.id, profile: auth.profile)
            } catch {
                print("🚨 Error getting secure link: \(error.localizedDescription)")
            }
        }
    }
}
