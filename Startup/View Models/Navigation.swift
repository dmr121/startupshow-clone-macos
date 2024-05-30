//
//  Navigation.swift
//  Startup
//
//  Created by David Rozmajzl on 5/17/24.
//

import SwiftUI

@Observable class Navigation {
    var mediaPaths = NavigationPath()
    var liveTVPaths = NavigationPath()
    var showSearchModel = false
    
    var binding_liveTVPaths: Binding<NavigationPath> {
        Binding {
            self.liveTVPaths
        } set: { newValue in
            self.liveTVPaths = newValue
        }
    }
}
