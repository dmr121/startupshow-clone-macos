//
//  Profiles.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import SwiftyJSON
import CachedAsyncImage

struct Profiles: View {
    @Environment(Authentication.self) private var auth
    
    @State private var profiles = [Profile]()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 16) {
                let width = geometry.size.width / (CGFloat(profiles.count) + 2.5)
                ForEach(profiles) { profile in
                    ProfileCard(profile, width: width)
                }
            }
            .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
            .transition(.opacity)
        }
        .task {
            await getProfiles()
        }
    }
}

// MARK: Views
fileprivate struct ProfileCard: View {
    @Environment(Authentication.self) private var auth
    
    let profile: Profile
    let width: CGFloat
    
    @State private var isHovering = false
    
    init(_ profile: Profile, width: CGFloat) {
        self.profile = profile
        self.width = width
    }
    
    var body: some View {
        Button {
            withAnimation { auth.profile = profile }
            
            do {
                let data = try JSONEncoder().encode(profile)
                let json = try JSON(data: data).rawString()
                UserDefaults.standard.setValue(json, forKey: K.profilePath)
            } catch {
                print("🚨 Error saving profile choice: \(error.localizedDescription)")
            }
        } label: {
            VStack(spacing: 8) {
                CachedAsyncImage(url: profile.avatarURL, urlCache: .imageCache) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color.gray
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: width / 2))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: width, height: width)
                .clipShape(Circle())
                
                Text(profile.name)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .fontWeight(.medium)
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .foregroundStyle(isHovering ? Color.accentColor: .label)
            }
            .contentShape(Rectangle())
        }
        .frame(width: width)
        .buttonStyle(.plain)
        .offset(CGSize(width: 0, height: isHovering ? -width/10: 0))
        .onHover { h in
            withAnimation(.spring(duration: 0.22)) { isHovering = h } }
    }
}

// MARK: Private Methods
extension Profiles {
    @MainActor
    private func getProfiles() async {
        do {
            let profiles = try await auth.getProfiles()
            withAnimation {
                self.profiles = profiles.sorted{ $0.profileNumber < $1.profileNumber }
            }
        } catch {
            print("🚨 Error getting profiles: \(error.localizedDescription)")
        }
    }
}
