//
//  LiveTVChannels.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

let channelGridColumns = [GridItem(.adaptive(minimum: 175, maximum: 225), spacing: 10)]

struct LiveTVChannels: View {
    @Environment(Authentication.self) private var auth
    @Environment(LiveTVCategoriesViewModel.self) private var liveTVVM
    
    @State private var selectedChannel: LiveTVChannelViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: channelGridColumns, spacing: 10) {
                    ForEach(liveTVVM.categoryChannels) { channel in
                        LiveTVChannelTile(channel, selectedChannel: $selectedChannel)
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
        .sheet(item: $selectedChannel) { channel in
            LiveTVChannelModal(channel)
                .frame(minWidth: 750, minHeight: 533)
                .frame(maxWidth: 1000, maxHeight: 710)
        }
        .onChange(of: liveTVVM.selectedCategory, { _, newCat in
            guard let newCat else { return }
            getChannels(for: newCat)
        })
        .task {
            do {
                try await liveTVVM.getCategories(profile: auth.profile)
                
                if liveTVVM.selectedCategory == nil {
                    liveTVVM.selectedCategory = liveTVVM.categories.first
                }
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Private methods
extension LiveTVChannels {
    private func getChannels(for category: Category) {
        Task {
            do {
                try await liveTVVM.getChannels(for: category, profile: auth.profile)
            } catch {
                print("🚨 Error fetching category channels: \(error.localizedDescription)")
            }
        }
    }
}
