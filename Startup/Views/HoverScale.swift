//
//  HoverScale.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI

struct HoverScale<Content: View>: View {
    let scale: CGFloat
    let highlight: Color?
    @ViewBuilder let content: Content
    
    @State private var isHovering = false
    
    // TODO: Maybe remove highlight
    init(scale: CGFloat, highlight: Color? = nil, content: () -> Content) {
        self.scale = scale
        self.highlight = highlight
        self.content = content()
    }
    
    var body: some View {
        content
            .onHover { h in
                withAnimation(.spring(duration: 0.22)) { isHovering = h } }
            .scaleEffect(isHovering ? scale: 1)
    }
}
