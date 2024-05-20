//
//  MediaDetailModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import AlertToast
import CachedAsyncImage
import Foundation

struct MediaDetailModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigation.self) private var navigation
    @Environment(Authentication.self) private var auth
    
    let media: MediaViewModel
    
    @State private var secureLink: String?
    @State private var favoriteSuccess = false
    @State private var unfavoriteSuccess = false
    @State private var favoriteSuccessMessage: String?
    @State private var unfavoriteSuccessMessage: String?
    @State private var season = 0
    
    init(_ media: MediaViewModel) {
        self.media = media
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    CachedAsyncImage(url: media.value.meta.fanart, urlCache: .imageCache) { image in
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
                        Text(media.value.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Actions
                        HStack(spacing: 20) {
                            if (media.value.seasons?.count ?? 0) == 0 {
                                Hover { isHovering in
                                    Button {
                                        navigation.paths.append(media)
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
                            }
                            
                            HStack(spacing: 15) {
                                if let trailerURL = media.value.meta.trailer {
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
                                                if media.value.is_favorite ?? false {
                                                    unfavoriteSuccessMessage = try await media.unfavorite(profile: auth.profile)
                                                    unfavoriteSuccess = true
                                                } else {
                                                    favoriteSuccessMessage = try await media.favorite(profile: auth.profile)
                                                    favoriteSuccess = true
                                                }
                                            } catch {
                                                print("🚨 Error toggling favorite movie: \(error.localizedDescription)")
                                            }
                                        }
                                    } label: {
                                        // Show solid star if movie is a favorite or if it's currently being marked as a favorite
                                        let showFavorite = (media.value.is_favorite ?? false) ? media.favoritingMedia ? false: true: media.favoritingMedia ? true: false
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
                                    Text(media.value.meta.year)
                                    
                                    // IMDB Rank
                                    HStack(spacing: 4) {
                                        Image("IMDB")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 27)
                                            .background(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                        
                                        Text(String(format: "%.1f", media.value.meta.rank))
                                        
                                        if let votes = Int(media.value.meta.votes)?.abbr {
                                            Text("(\(votes))")
                                                .font(.subheadline)
                                                .opacity(0.75)
                                        }
                                    }
                                    
                                    // Runtime
                                    if let numSeasons = media.value.seasons?.count {
                                        Text("\(numSeasons) Season\(numSeasons > 1 ? "s": "")")
                                    } else {
                                        if let minutes = Int(media.value.meta.runtime) {
                                            Text(minutesToHoursAndMinutes(minutes))
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .foregroundStyle(.secondary)
                                
                                HStack(spacing: 16) {
                                    // MPPA Rating
                                    Text(media.value.meta.mppa)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 1.5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 1)
                                                .stroke(.secondary)
                                        }
                                    
                                    // Genres
                                    Text(media.value.meta.genres)
                                    
                                    Spacer()
                                }
                                
                                Text(media.value.meta.plot)
                                    .lineSpacing(6)
                                    .padding(.top)
                            }
                            .frame(width: geometry.size.width * 0.6)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Group {
                                    Text("Cast: ")
                                        .foregroundStyle(.secondary.opacity(0.6)) +
                                    Text(media.value.meta.cast)
                                }
                                .lineSpacing(4)
                                
                                if let director = media.value.meta.director {
                                    Group {
                                        Text("Director: ")
                                            .foregroundStyle(.secondary.opacity(0.6)) +
                                        Text(director)
                                    }
                                    .lineSpacing(4)
                                }
                                
                                if let writer = media.value.meta.writer {
                                    Group {
                                        Text("Writer: ")
                                            .foregroundStyle(.secondary.opacity(0.6)) +
                                        Text(writer)
                                    }
                                    .lineSpacing(4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 28)
                        
                        Episodes()
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

// MARK: Views {
extension MediaDetailModal {
    @ViewBuilder private func Episodes() -> some View {
        if let seasons = media.value.seasons {
            VStack(alignment: .leading, spacing: 0) {
                Menu {
                    ForEach(Array(seasons.enumerated()), id: \.offset) { index, _ in
                        Button("Season \(index + 1)") {
                            self.season = index
                        }
                        Divider()
                    }
                } label: {
                    Text("Season \(season + 1)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .fixedSize()
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
                .menuStyle(.borderlessButton)
                
                ForEach(seasons[season]) { episode in
                    Hover { isHovering in
                        Button {
                            media.type = .tv(episode.season, episode.episode)
                            navigation.paths.append(media)
                        } label: {
                            HStack(spacing: 13) {
                                CachedAsyncImage(url: episode.screenshot, urlCache: .imageCache) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                }
                                .frame(width: 200, height: 112.5)
                                .background(.secondary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(episode.title ?? "Episode \(episode.episode)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    if let released = episode.released {
                                        Text(released.formatted(date: .long, time: .omitted))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Text(episode.plot)
                                        .lineSpacing(4)
                                        .padding(.top, 4)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(isHovering ? Color.secondary.opacity(0.1): .clear)
                        }
                        .buttonStyle(.plain)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .scaleEffect(isHovering ? 1.03: 1)
                    }
                }
            }
            .padding(.top, 28)
        } else {
            EmptyView()
        }
    }
}
