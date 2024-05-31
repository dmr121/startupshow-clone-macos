//
//  LiveTVChannelModal.swift
//  Startup
//
//  Created by David Rozmajzl on 5/27/24.
//

import SwiftUI
import AlertToast
import CachedAsyncImage
import Lottie

struct LiveTVChannelModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Navigation.self) private var navigation
    @Environment(Authentication.self) private var auth
    @Environment(LiveTVCategoriesViewModel.self) private var liveTVVM
    @Environment(FavoritesViewModel.self) private var favorites
    
    let channel: LiveTVChannelViewModel
    
    @State private var epgs = [EPG]()
    @State private var favoriteSuccess = false
    @State private var unfavoriteSuccess = false
    @State private var favoriteSuccessMessage: String?
    @State private var unfavoriteSuccessMessage: String?
    
    init(_ channel: LiveTVChannelViewModel) {
        self.channel = channel
    }
    
    private var guideDays: [String: [EPG]] {
        return epgs.reduce(into: [:]) { partialResult, epg in
            if let key = epg.start.formatted("yyyy-MM-dd") {
                if partialResult.contains(where: { $0.key == key }) {
                    partialResult[key]!.append(epg)
                } else {
                    partialResult[key] = [epg]
                }
            }
        }
    }
    
    private var sortedDays: [Dictionary<String, [EPG]>.Keys.Element] {
        return guideDays.keys.sorted(by: <)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scroll in
                ScrollView {
                    Days(geometry: geometry)
                        .onChange(of: epgs) { _, newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                guard let playingNow = newValue.first(where: {
                                    $0.start <= Date() && $0.stop >= Date()
                                }) else { return }
                                withAnimation {
                                    scroll.scrollTo(playingNow.id, anchor: .center)
                                }
                            }
                        }
                }
                .mask(LinearGradient(stops: [
                    .init(color: .black, location: 0.85),
                    .init(color: .clear, location: 1)
                ], startPoint: .top, endPoint: .bottom))
            }
            
            if !channel.fetchingEpisodeGuide {
                Controls()
            } else {
                ZStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Dismiss button
            VStack {
                HStack {
                    Hover { isHovering in
                        Button {
                            dismiss()
                        } label: {
                            ZStack {
                                Circle().fill(.ultraThinMaterial).colorMultiply(.gray)
                                
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
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(12)
        }
        .disabled(channel.fetchingEpisodeGuide)
        .task {
            do {
                self.epgs = try await channel.getEpisodeGuide()
            } catch {
                print("🚨 Error fetching categories: \(error.localizedDescription)")
            }
        }
        .toast(isPresenting: $favoriteSuccess){
            AlertToast(displayMode: .hud, type: .systemImage("star.fill", .white), title: "Saved Favorite", subTitle: favoriteSuccessMessage)
        }
        
        .toast(isPresenting: $unfavoriteSuccess){
            AlertToast(displayMode: .hud, type: .systemImage("star.slash", .white), title: "Removed Favorite", subTitle: unfavoriteSuccessMessage)
        }
    }
}

// MARK: Views
extension LiveTVChannelModal {
    @ViewBuilder private func Controls() -> some View {
        VStack {
            Spacer()
            
            HStack(spacing: 15) {
                Spacer()
                
                CachedAsyncImage(url: channel.value.logo) { image in
                    image.image?.resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 35, height: 35)
                
                Hover { isHovering in
                    Button {
                        Task {
                            await toggleFavorite()
                        }
                    } label: {
                        // Show solid star if movie is a favorite or if it's currently being marked as a favorite
                        let showFavorite = (channel.value.is_favorite ?? false) ? channel.favoritingMedia ? false: true: channel.favoritingMedia ? true: false
                        Label("Favorite", systemImage: showFavorite ? "star.fill": "star")
                            .font(.system(size: 16))
                            .labelStyle(.iconOnly)
                            .frame(width: 34, height: 34)
                            .background(
                                Group {
                                    if isHovering {
                                        Rectangle().fill(.regularMaterial)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(Circle())
                            .blendMode(.screen)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isHovering ? 1.05: 1)
                }
                
                Hover { isHovering in
                    Button {
                        navigation.mediaPaths.append(channel)
                    } label: {
                        HStack {
                            Label("Watch", systemImage: "play.fill")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .scaleEffect(isHovering ? 1.05: 1, anchor: .bottomTrailing)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(
                LinearGradient(colors: [Color.background.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
            )
        }
    }
    struct Episode: View {
        let epg: EPG
        let isToday: Bool
        
        @State private var expanded = false
        @State private var animateAntenna = false
        
        init(_ epg: EPG, isToday: Bool) {
            self.epg = epg
            self.isToday = isToday
        }
        
        private var playingNow: Bool {
            return epg.start <= Date() && epg.stop >= Date()
        }
        
        private var description: String? {
            return (epg.desc?.trimmed().count ?? 0) > 0 ? epg.desc!: nil
        }
        
        var body: some View {
            Hover { isHovering in
                Button {
                    withAnimation { expanded.toggle() }
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(epg.title)
                                .fontWeight(.semibold)
                            
                            HStack {
                                if let start = epg.start.formatted("h:mm a") {
                                    Text(start)
                                }
                                
                                Text("-")
                                
                                if let stop = epg.stop.formatted("h:mm a") {
                                    Text(stop)
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .padding(.leading)
                            
                            if expanded, let description {
                                Text(description)
                                    .font(.subheadline)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            if playingNow {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .symbolEffect(.variableColor.reversing.iterative, options: .repeating, value: animateAntenna)
                                    .foregroundStyle(Color.accentColor)
                                    .onAppear {
                                        withAnimation { animateAntenna.toggle() }
                                    }
                            }
                            
                            if description != nil {
                                Label("Toggle expand", systemImage: expanded ? "chevron.up": "chevron.down")
                                    .labelStyle(.iconOnly)
                                    .contentTransition(.symbolEffect(.replace))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(isHovering ? Color.backgroundLightest: .backgroundLighter)
                    .overlay {
                        Group {
                            if isHovering {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray, lineWidth: 2)
                            }
                            
                            if playingNow {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .opacity((isToday || playingNow) ? 1: 0.4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    @ViewBuilder private func Days(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(sortedDays, id: \.self) { day in
                let isToday = isToday(day)
                let date = toDate(day, format: "yyyy-MM-dd")
                let dayOfWeek = date?.formatted("EEEE")
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(isToday ? "Today": dayOfWeek ?? day)
                            .font(.title2)
                        
                        if let dateString = date?.formatted("MM/dd") {
                            Text(dateString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach((guideDays[day] ?? []).sorted { $0.start < $1.start }) { epg in
                            Episode(epg, isToday: isToday)
                                .id(epg.id)
                        }
                    }
                }
                
                if sortedDays.firstIndex(of: day) != sortedDays.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .padding(.vertical, 40)
    }
    
    @ViewBuilder private func Tile(_ channel: Channel) -> some View {
        GeometryReader { geometry in
            HoverScale(scale: 1.05) {
                Button {
                    navigation.mediaPaths.append(channel)
                } label: {
                    ZStack {
                        Color.red
                        
                        VStack {
                            CachedAsyncImage(url: channel.logo, urlCache: .imageCache) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ZStack {
                                    Image(systemName: "tv")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .opacity(0.3)
                                        .padding(.bottom)
                                }
                                .foregroundStyle(.gray)
                            }
                            .frame(width: geometry.size.width * 0.4444, height: geometry.size.width * 0.4444)
                            
                            Text(channel.name)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
extension LiveTVChannelModal {
    private func toggleFavorite() async {
        do {
            if channel.value.is_favorite ?? false {
                unfavoriteSuccessMessage = try await channel.unfavorite(profile: auth.profile)
                unfavoriteSuccess = true
                favorites.liveTV.removeAll { $0.value.id == channel.value.id }
                
                guard let index = liveTVVM.categoryChannels.firstIndex(where: { channelVM in
                    channelVM.value.id == channel.value.id
                }) else { return }
                liveTVVM.categoryChannels[index].value.toggleFavorite(to: false)
            } else {
                favoriteSuccessMessage = try await channel.favorite(profile: auth.profile)
                favoriteSuccess = true
                favorites.liveTV.append(channel)
                
                guard let index = liveTVVM.categoryChannels.firstIndex(where: { channelVM in
                    channelVM.value.id == channel.value.id
                }) else { return }
                liveTVVM.categoryChannels[index].value.toggleFavorite(to: true)
            }
        } catch {
            print("🚨 Error toggling favorite channel: \(error.localizedDescription)")
        }
    }
    
    private func isToday(_ dateString: String) -> Bool {
        guard let todayFormatted = Date().formatted("yyyy-MM-dd") else { return false }
        return dateString == todayFormatted
    }
}
