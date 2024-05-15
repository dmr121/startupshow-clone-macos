//
//  Constants.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import Foundation
import KeychainAccess

class K {
    static let apiURLBase = "https://tvnow.best/api"
    static let mediaURLBase = "https://media.tvnow.best"
    static let keychain = Keychain(service: "com.davidrozmajzl.macos.Startup")
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let profilePath = "profile/profile"
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
}
