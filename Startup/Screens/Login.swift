//
//  Login.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

fileprivate enum FocusField {
    case url
}

struct Login: View {
    @Environment(Authentication.self) private var auth
    
    @State private var url = ""
    
    @FocusState private var focus: FocusField?
    
    var body: some View {
        VStack {
            TextField(text: $url, prompt: Text("Enter an m3u url")) {
                Text("URL Input Field")
            }
            .focused($focus, equals: FocusField.url)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                if focus == .url {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(.accent.opacity(0.6), lineWidth: 2)
                }
            }
            .onAppear {
                focus = .url
            }
            
            Button("Login") {
                Task {
                    do {
                        try await auth.login(with: url)
                    } catch {
                        print("🚨 Error logging in: \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: 300)
    }
}

#Preview {
    Login()
}
