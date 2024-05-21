//
//  HoverScale.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

struct HoverScale<Content: View>: View {
    let scale: CGFloat
    @ViewBuilder let content: Content
    
    @State private var isHovering = false
    
    init(scale: CGFloat, content: () -> Content) {
        self.scale = scale
        self.content = content()
    }
    
    var body: some View {
        content
            .onHover { h in
                withAnimation(.spring(duration: 0.22)) { isHovering = h } }
            .scaleEffect(isHovering ? scale: 1)
    }
}
