//
//  ContentView.swift
//  Startup
//
//  Created by David Rozmajzl on 5/14/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(Authentication.self) private var auth
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        ZStack {
            Group {
                if auth.authToken != nil,
                   let expiration = auth.authTokenExpiration,
                   expiration > Date() {
                    if let _ = auth.user {
                        if let _ = auth.profile {
                            MainView()
                                .transition(.opacity)
                        } else {
                            Profiles()
                                .transition(.opacity)
                        }
                    }
                } else {
                    Welcome()
                        .transition(.opacity)
                }
            }
            .blur(radius: (auth.attemptingToFetchUser || auth.loggingIn) ? 20: 0)
            .disabled(auth.attemptingToFetchUser || auth.loggingIn)
            .zIndex(0)
            
            if auth.attemptingToFetchUser || auth.loggingIn {
                ProgressView()
                    .zIndex(1)
            }
        }
        .task {
            do {
                withAnimation { auth.attemptingToFetchUser = true }
                try await auth.getUser()
            } catch {
                print("🚨 Error fetching user: \(error.localizedDescription)")
            }
            withAnimation { auth.attemptingToFetchUser = false }
        }
    }
}
