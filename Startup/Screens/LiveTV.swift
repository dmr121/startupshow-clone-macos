//
//  LiveTV.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

struct LiveTV: View {
    @Environment(Authentication.self) private var auth
    @Environment(LiveTVCategoriesViewModel.self) private var liveTVVM
    
    let columns = [GridItem(.adaptive(minimum: 175, maximum: 225), spacing: 10)]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(liveTVVM.categories) { category in
                        Tile()
                    }
                }
                .padding(10)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu(liveTVVM.selectedCategory != nil ? liveTVVM.selectedCategory!.name: "Select a category") {
                    ForEach(liveTVVM.categories) { category in
                        Button {
                            liveTVVM.selectedCategory = category
                        } label: {
                            Text(category.name)
                            
                            if liveTVVM.selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .resizable()
                            }
                        }
                        
                        Divider()
                    }
                }
                
            }
        }
        .task {
            do {
                try await liveTVVM.getCategories(profile: auth.profile)
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Views
extension LiveTV {
    @ViewBuilder private func Tile() -> some View {
        GeometryReader { geo in
            Color.gray
            Text("channel.name")
                .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: Private methods
extension LiveTV {
    private func getChannels(for category: Category) {
        Task {
            do {
//                try await
            } catch {
                print("🚨 Error fetching category channels: \(error.localizedDescription)")
            }
        }
    }
}
