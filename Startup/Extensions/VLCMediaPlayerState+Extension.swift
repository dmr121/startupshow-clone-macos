//
//  VLCMediaPlayerState+Extension.swift
//  Startup
//
//  Created by David Rozmajzl on 5/18/24.
//

import VLCKit

extension VLCMediaPlayerState {
    public var label: String {
        switch self {
        case .buffering:
            return "Buffering"
        case .ended:
            return "Ended"
        case .error:
            return "Error"
        case .esAdded:
            return "Elementary Stream Added"
        case .opening:
            return "Opening"
        case .paused:
            return "Paused"
        case .playing:
            return "Playing"
        case .stopped:
            return "Stopped"
        @unknown default:
            return "UNKNOWN"
        }
    }
}
