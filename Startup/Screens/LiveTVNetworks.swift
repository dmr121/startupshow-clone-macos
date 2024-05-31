//
//  LiveTV.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import CachedAsyncImage

struct LiveTVNetworks: View {
    @Environment(Navigation.self) private var navigation
    @Environment(Authentication.self) private var auth
    @Environment(LiveTVCategoriesViewModel.self) private var liveTVVM
    
    @State private var selectedChannel: LiveTVChannelViewModel?
    
    let columns = [GridItem(.adaptive(minimum: 175, maximum: 225), spacing: 10)]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(liveTVVM.categoryChannels) { channel in
                        Tile(channel)
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

// MARK: Views
extension LiveTVNetworks {
    @ViewBuilder private func Tile(_ channel: LiveTVChannelViewModel) -> some View {
        GeometryReader { geometry in
            Hover { isHovering in
                Button {
                    selectedChannel = channel
                } label: {
                    ZStack {
                        isHovering ? Color.backgroundLighter: .background
                        
                        VStack {
                            CachedAsyncImage(url: channel.value.logo, urlCache: .imageCache) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "tv")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: geometry.size.width * 0.4444, height: geometry.size.width * 0.4444)
                            
                            Text(channel.value.name)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                if isHovering {
                                    Hover { buttonHovering in
                                        Button {
                                            navigation.mediaPaths.append(channel)
                                        } label: {
                                            Label("Watch", systemImage: "play.fill")
                                                .labelStyle(.iconOnly)
                                                .font(.system(size: 18))
                                                .frame(width: 30, height: 30)
                                                .background(buttonHovering ? .accent: .white)
                                                .foregroundStyle(buttonHovering ? .white: .black)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .scaleEffect(buttonHovering ? 1.12: 1, anchor: .bottomTrailing)
                                    }
                                }
                            }
                        }
                        .padding(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
    }
}

// MARK: Private methods
extension LiveTVNetworks {
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
