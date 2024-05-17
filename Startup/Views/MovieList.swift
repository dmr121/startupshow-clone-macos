//
//  MovieList.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI
import CachedAsyncImage

fileprivate let columnCount = 6
fileprivate let cardPadding: CGFloat = 4

struct MovieList: View {
    @Environment(Authentication.self) private var auth
    @Environment(MoviesViewModel.self) private var moviesViewModel
    
    let category: Category
    let geometry: GeometryProxy
    
    private var hPadding: CGFloat {
        return geometry.size.width * 0.065
    }
    private var height: CGFloat {
     return (geometry.size.width - (cardPadding * 2 * CGFloat(columnCount)) - (hPadding * 2)) * 1.5 / CGFloat(columnCount)
    }
    
    var body: some View {
        Carousel([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19], columns: columnCount, height: height, horizontalPadding: hPadding) { movie in
            MovieCard("\(movie)")
                .padding(.horizontal, cardPadding)
        }
//        .task {
//            do {
//                if category.id != "1" { return }
//                print("HERE 1")
////                withAnimation { moviesViewModel.fetchingMoviesForCategoryIds.insert(category.id) }
//                try await moviesViewModel.getMovies(for: category, profile: auth.profile)
//                print("HERE 2")
//            } catch {
//                print("🚨 Error fetching user: \(error.localizedDescription)")
//            }
////            withAnimation { moviesViewModel.fetchingMoviesForCategoryIds.remove(category.id) }
//        }
    }
}

// MARK: Views
extension MovieList {
    @ViewBuilder private func MovieCard(_ movie: String) -> some View {
        HoverScale(scale: 1.05) {
            GeometryReader { geometry in
                Button {
                    print(movie)
//                    selectedMovie = Stringg(value:movie)
                } label: {
                    ZStack {
                        CachedAsyncImage(url: URL(string: "https://picsum.photos/seed/\(movie)/500/700")!, urlCache: .imageCache) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                        
                        Text(movie)
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
