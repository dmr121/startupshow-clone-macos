//
//  Movies.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import CachedAsyncImage

fileprivate let columnCount = 6

struct Movies: View {
    @Environment(Authentication.self) private var auth
    @Environment(MoviesViewModel.self) private var moviesViewModel
    
    @State private var selectedMovie: Movie?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MoviesList(geometry: geometry)
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailModal(movie)
                    .frame(minWidth: 750, minHeight: 400)
                    .frame(maxWidth: 1000, maxHeight: 533)
            }
        }
        .task {
            do {
                withAnimation { moviesViewModel.fetchingCategories = true }
                try await moviesViewModel.getCategories(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
            withAnimation { moviesViewModel.fetchingCategories = false }
        }
    }
}

// MARK: Views
extension Movies {
    @ViewBuilder private func MoviesList(geometry: GeometryProxy) -> some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            ForEach(moviesViewModel.categories) { category in
                let cardPadding: CGFloat = 4
                let hPadding = geometry.size.width * 0.065
                let height = (geometry.size.width - (cardPadding * 2 * CGFloat(columnCount)) - (hPadding * 2)) * 1.5 / CGFloat(columnCount)
                
                Section {
                    Carousel(category.movies, columns: columnCount, height: height, horizontalPadding: hPadding) { movie in
                        MovieCard(movie)
                            .padding(.horizontal, cardPadding)
                    }
                } header: {
                    Text(category.value.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 11)
                        .padding(.bottom, -8)
                        .padding(.leading, cardPadding * 2)
                }
            }
        }
        .padding(.vertical)
        .blur(radius: moviesViewModel.fetchingCategories ? 20: 0)
        .disabled(moviesViewModel.fetchingCategories)
    }
    
    @ViewBuilder private func MovieCard(_ movie: Movie) -> some View {
        HoverScale(scale: 1.05) {
            GeometryReader { geometry in
                Button {
                    withAnimation { selectedMovie = movie }
                } label: {
                    CachedAsyncImage(url: movie.meta.poster, urlCache: .imageCache) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

//#Preview {
//    Movies()
//}
