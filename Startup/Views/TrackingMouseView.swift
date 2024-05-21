//
//  TrackingMouseView.swift
//  Startup
//
//  Created by David Rozmajzl on 5/20/24.
//

import SwiftUI
import AppKit

extension View {
    func trackingMouse(onMove: @escaping (NSPoint) -> Void, onEntered: @escaping (NSPoint) -> Void, onExited: @escaping (NSPoint) -> Void) -> some View {
        TrackinAreaView(onMove: onMove, onEntered: onEntered, onExited: onExited) { self }
    }
}

struct TrackinAreaView<Content>: View where Content : View {
    let onMove: (NSPoint) -> Void
    let onEntered: (NSPoint) -> Void
    let onExited: (NSPoint) -> Void
    let content: () -> Content
    
    init(onMove: @escaping (NSPoint) -> Void, onEntered: @escaping (NSPoint) -> Void, onExited: @escaping (NSPoint) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onMove = onMove
        self.onEntered = onEntered
        self.onExited = onExited
        self.content = content
    }
    
    var body: some View {
        TrackingAreaRepresentable(onMove: onMove, onEntered: onEntered, onExited: onExited, content: self.content())
    }
}

struct TrackingAreaRepresentable<Content>: NSViewRepresentable where Content: View {
    let onMove: (NSPoint) -> Void
    let onEntered: (NSPoint) -> Void
    let onExited: (NSPoint) -> Void
    let content: Content
    
    func makeNSView(context: Context) -> NSHostingView<Content> {
        return TrackingNSHostingView(onMove: onMove, onEntered: onEntered, onExited: onExited, rootView: self.content)
    }
    
    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
    }
}

class TrackingNSHostingView<Content>: NSHostingView<Content> where Content : View {
    let onMove: (NSPoint) -> Void
    let onEntered: (NSPoint) -> Void
    let onExited: (NSPoint) -> Void
    
    init(onMove: @escaping (NSPoint) -> Void, onEntered: @escaping (NSPoint) -> Void, onExited: @escaping (NSPoint) -> Void, rootView: Content) {
        self.onMove = onMove
        self.onEntered = onEntered
        self.onExited = onExited
        
        super.init(rootView: rootView)
        
        setupTrackingArea()
    }
    
    required init(rootView: Content) {
        fatalError("init(rootView:) has not been implemented")
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        self.addTrackingArea(NSTrackingArea.init(rect: .zero, options: options, owner: self, userInfo: nil))
    }
    
    override func mouseMoved(with event: NSEvent) {
        self.onMove(self.convert(event.locationInWindow, from: nil))
    }
    
    override func mouseExited(with event: NSEvent) {
        self.onExited(self.convert(event.locationInWindow, from: nil))
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.onEntered(self.convert(event.locationInWindow, from: nil))
    }
}
