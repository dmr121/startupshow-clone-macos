//
//  FullScreenMonitor.swift
//  Startup
//
//  Created by David Rozmajzl on 5/20/24.
//

import SwiftUI
import AppKit

struct FullscreenMonitor: ViewModifier {
    @Binding var isFullscreen: Bool
    
    func body(content: Content) -> some View {
        content
            .background(FullscreenGetter(isFullscreen: $isFullscreen))
    }
    
    struct FullscreenGetter: NSViewRepresentable {
        @Binding var isFullscreen: Bool
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            DispatchQueue.main.async {
                if let window = view.window {
                    self.isFullscreen = window.styleMask.contains(.fullScreen)
                    NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.windowDidEnterFullScreen(_:)), name: NSWindow.didEnterFullScreenNotification, object: window)
                    NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.windowDidExitFullScreen(_:)), name: NSWindow.didExitFullScreenNotification, object: window)
                }
            }
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(isFullscreen: $isFullscreen)
        }
        
        class Coordinator: NSObject {
            @Binding var isFullscreen: Bool
            
            init(isFullscreen: Binding<Bool>) {
                _isFullscreen = isFullscreen
            }
            
            @objc func windowDidEnterFullScreen(_ notification: Notification) {
                isFullscreen = true
            }
            
            @objc func windowDidExitFullScreen(_ notification: Notification) {
                isFullscreen = false
            }
        }
    }
}

extension View {
    func monitorFullscreen(isFullscreen: Binding<Bool>) -> some View {
        self.modifier(FullscreenMonitor(isFullscreen: isFullscreen))
    }
}

