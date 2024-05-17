//
//  MovieDetailModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI

struct MovieDetailModal: View {
    let movie: Movie
    
    init(_ movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        ScrollView {
            ForEach(0..<200) { _ in
                Text(movie.title)
            }
        }
    }
}
