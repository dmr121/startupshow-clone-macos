//
//  Hover.swift
//  Startup
//
//  Created by David Rozmajzl on 5/16/24.
//

import SwiftUI

struct Hover<Content>: View where Content: View {
    let hovering: (Bool) -> Content
    
    @State private var isHovering = false
    
    var body: some View {
        hovering(isHovering)
            .onHover { h in withAnimation { isHovering = h } }
    }
}
