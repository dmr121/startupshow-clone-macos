//
//  MovieDetailModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import AlertToast
import CachedAsyncImage
import Foundation

struct MovieDetailModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigation.self) private var navigation
    @Environment(Authentication.self) private var auth
    
    let movie: MovieViewModel
    
    @State private var secureLink: String?
    @State private var favoriteSuccess = false
    @State private var unfavoriteSuccess = false
    @State private var favoriteSuccessMessage: String?
    @State private var unfavoriteSuccessMessage: String?
    
    init(_ movie: MovieViewModel) {
        self.movie = movie
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    CachedAsyncImage(url: movie.value.meta.fanart, urlCache: .imageCache) { image in
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
                }
                
                // Details
                VStack(alignment: .leading, spacing: 0) {
                    LinearGradient(colors: [Color.background, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(movie.value.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Actions
                        HStack(spacing: 20) {
                            Hover { isHovering in
                                Button {
                                    navigation.paths.append(movie)
                                } label: {
                                    HStack {
                                        Label("Play", systemImage: "play.fill")
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
                                if let trailerURL = movie.value.meta.trailer {
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
                                    Button {
                                        Task {
                                            do {
                                                if movie.value.is_favorite ?? false {
                                                    unfavoriteSuccessMessage = try await movie.unfavorite(profile: auth.profile)
                                                    unfavoriteSuccess = true
                                                } else {
                                                    favoriteSuccessMessage = try await movie.favorite(profile: auth.profile)
                                                    favoriteSuccess = true
                                                }
                                            } catch {
                                                print("🚨 Error toggling favorite movie: \(error.localizedDescription)")
                                            }
                                        }
                                    } label: {
                                        // Show solid star if movie is a favorite or if it's currently being marked as a favorite
                                        let showFavorite = (movie.value.is_favorite ?? false) ? movie.favoritingMovie ? false: true: movie.favoritingMovie ? true: false
                                        Label("Favorite", systemImage: showFavorite ? "star.fill": "star")
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
                                    Text(movie.value.meta.year)
                                    
                                    // IMDB Rank
                                    HStack(spacing: 4) {
                                        Image("IMDB")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 27)
                                            .background(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                        
                                        Text(String(format: "%.1f", movie.value.meta.rank))
                                        
                                        if let votes = Int(movie.value.meta.votes)?.abbr {
                                            Text("(\(votes))")
                                                .font(.subheadline)
                                                .opacity(0.75)
                                        }
                                    }
                                    
                                    // Runtime
                                    if let minutes = Int(movie.value.meta.runtime) {
                                        Text(minutesToHoursAndMinutes(minutes))
                                    }
                                }
                                .foregroundStyle(.secondary)
                                
                                HStack(spacing: 16) {
                                    // MPPA Rating
                                    Text(movie.value.meta.mppa)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 1.5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 1)
                                                .stroke(.secondary)
                                        }
                                    
                                    // Genres
                                    Text(movie.value.meta.genres)
                                }
                                
                                Text(movie.value.meta.plot)
                                    .lineSpacing(6)
                                    .padding(.top)
                            }
                            .frame(width: geometry.size.width * 0.6)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Group {
                                    Text("Cast: ")
                                        .foregroundStyle(.secondary.opacity(0.6)) +
                                    Text(movie.value.meta.cast)
                                }
                                .lineSpacing(4)
                                
                                Group {
                                    Text("Director: ")
                                        .foregroundStyle(.secondary.opacity(0.6)) +
                                    Text(movie.value.meta.director)
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
            
            // Dismiss button
            VStack {
                HStack {
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
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(12)
        }
        .background(Color.background)
        .toast(isPresenting: $favoriteSuccess){
            AlertToast(displayMode: .hud, type: .systemImage("star.fill", .white), title: "Saved Favorite", subTitle: favoriteSuccessMessage)
        }
        
        .toast(isPresenting: $unfavoriteSuccess){
            AlertToast(displayMode: .hud, type: .systemImage("star.slash", .white), title: "Removed Favorite", subTitle: unfavoriteSuccessMessage)
        }
    }
}
