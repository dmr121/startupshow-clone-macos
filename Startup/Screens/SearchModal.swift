//
//  SearchModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/24/24.
//

import SwiftUI

fileprivate enum FocusField {
    case search
}

struct SearchModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Authentication.self) private var auth
    
    @StateObject private var searchVM: SearchViewModel
    @State private var selectedMedia: MediaViewModel?
    
    @FocusState private var focus: FocusField?
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
    
    init(auth: Authentication) {
        _searchVM = StateObject(wrappedValue: SearchViewModel(profile: auth.profile))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
                Section {
                    Section {
                        if searchVM.media.count > 0 {
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                ForEach(searchVM.media) { media in
                                    MediaCard(media, selected: $selectedMedia)
                                        .aspectRatio(2/3, contentMode: .fill)
                                }
                            }
                        } else {
                            ZStack {
                                Image(systemName: "popcorn.fill")
                                    .font(.system(size: 75))
                                    .padding(.top, 120)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(.secondary.opacity(0.1))
                        }
                    }
                    .padding([.horizontal, .bottom])
                } header: {
                    VStack(spacing: 16) {
                        HStack(spacing: 14) {
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
                            
                            TextField(text: $searchVM.searchQuery, prompt: Text("Type to search...")) {
                                Text("Search Field")
                            }
                            .focused($focus, equals: FocusField.search)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .overlay {
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.backgroundLighter)
                            }
                        }
                        
                        Picker(selection: $searchVM.type) {
                            ForEach(SearchType.allCases) { type in
                                Text(type.rawValue)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 400)
                    }
                    .padding()
                    .background(
                        LinearGradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color.background, location: 0.32)
                        ], startPoint: .bottom, endPoint: .top)
                    )
                    .onAppear {
                        focus = .search
                    }
                }
            }
        }
        .background(Color.background)
        .sheet(item: $selectedMedia) { media in
            MediaDetailModal(media)
                .frame(minWidth: 750, minHeight: 533)
                .frame(maxWidth: 1000, maxHeight: 710)
        }
    }
}

//#Preview {
//    SearchModal()
//}
