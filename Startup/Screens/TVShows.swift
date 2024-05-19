//
//  TVShows.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import CachedAsyncImage

fileprivate let columnCount = 6

struct TVShows: View {
    @Environment(Authentication.self) private var auth
    @Environment(TVCategoriesViewModel.self) private var tvCategoriesViewModel
    
    @State private var selectedShow: MediaViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                TVList(geometry: geometry)
            }
            .sheet(item: $selectedShow) { tvShow in
                MediaDetailModal(tvShow)
                    .frame(minWidth: 750, minHeight: 533)
                    .frame(maxWidth: 1000, maxHeight: 710)
            }
        }
        .task {
            do {
                withAnimation { tvCategoriesViewModel.fetchingCategories = true }
                try await tvCategoriesViewModel.getCategories(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
            withAnimation { tvCategoriesViewModel.fetchingCategories = false }
        }
    }
}

// MARK: Views
extension TVShows {
    @ViewBuilder private func TVList(geometry: GeometryProxy) -> some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            ForEach(tvCategoriesViewModel.categories) { category in
                Section {
                    Carousel(category.media, columns: columnCount, padding: 8, geometry: geometry) { tvShow in
                        MediaCard(tvShow, selected: $selectedShow)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(2/3, contentMode: .fill)
                    }
                } header: {
                    Text(category.value.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 11)
                        .padding(.bottom, -12)
                        .padding(.leading, 6 * 2)
                }
            }
        }
        .padding(.vertical)
        .blur(radius: tvCategoriesViewModel.fetchingCategories ? 20: 0)
        .disabled(tvCategoriesViewModel.fetchingCategories)
    }
}
