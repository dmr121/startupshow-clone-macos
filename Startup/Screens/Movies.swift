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
    @Environment(MovieCategoriesViewModel.self) private var movieCategoriesViewModel
    
    @State private var selectedMovie: MovieViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MoviesList(geometry: geometry)
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailModal(movie)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
        }
        .task {
            do {
                withAnimation { movieCategoriesViewModel.fetchingCategories = true }
                try await movieCategoriesViewModel.getCategories(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
            withAnimation { movieCategoriesViewModel.fetchingCategories = false }
        }
    }
}

// MARK: Views
extension Movies {
    @ViewBuilder private func MoviesList(geometry: GeometryProxy) -> some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            ForEach(movieCategoriesViewModel.categories) { category in
                Section {
                    Carousel(category.movies, columns: columnCount, geometry: geometry) { movie in
                        MovieCard(movie)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(2/3, contentMode: .fill)
                    }
                } header: {
                    Text(category.value.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 11)
                        .padding(.bottom, -8)
                        .padding(.leading, 6 * 2)
                }
            }
        }
        .padding(.vertical)
        .blur(radius: movieCategoriesViewModel.fetchingCategories ? 20: 0)
        .disabled(movieCategoriesViewModel.fetchingCategories)
    }
    
    @ViewBuilder private func MovieCard(_ movie: MovieViewModel) -> some View {
        GeometryReader { geometry in
            HoverScale(scale: 1.05) {
                Button {
                    withAnimation { selectedMovie = movie }
                } label: {
                    CachedAsyncImage(url: movie.value.meta.poster, urlCache: .imageCache) { image in
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

//#Preview {
//    Movies()
//}
