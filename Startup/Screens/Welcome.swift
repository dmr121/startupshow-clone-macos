//
//  Welcome.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

fileprivate enum Path {
    case welcome
    case login
}

struct Welcome: View {
    @State private var navigation = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigation) {
            Group {
                Button("Login") {
                    navigation.append(Path.login)
                }
            }
            .navigationDestination(for: Path.self) { path in
                switch path {
                case .welcome:
                    Welcome()
                case .login:
                    Login()
                }
            }
        }
    }
}

//#Preview {
//    Welcome()
//}
