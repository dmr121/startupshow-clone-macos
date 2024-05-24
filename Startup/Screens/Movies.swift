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
    
    @State private var selectedMovie: MediaViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MoviesList(geometry: geometry)
            }
            .sheet(item: $selectedMovie) { movie in
                MediaDetailModal(movie)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
        }
        .task {
            print("🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 QUEEF")
            do {
                try await movieCategoriesViewModel.getCategories(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Views
extension Movies {
    @ViewBuilder private func MoviesList(geometry: GeometryProxy) -> some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            ForEach(movieCategoriesViewModel.categories) { category in
                if category.media.count > 0 {
                    Section {
                        Carousel(category.media, columns: columnCount, geometry: geometry) { movie in
                            MediaCard(movie, selected: $selectedMovie)
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
                } else {
                    EmptyView()
                }
            }
        }
        .padding(.vertical)
        .blur(radius: movieCategoriesViewModel.fetchingCategories ? 20: 0)
        .disabled(movieCategoriesViewModel.fetchingCategories)
    }
}

//#Preview {
//    Movies()
//}
