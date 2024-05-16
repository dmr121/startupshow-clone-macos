//
//  AuthenticationViewModel.swift
//  Startup
//
//  Created by David Rozmajzl on 5/15/24.
//

import SwiftUI
import SwiftyJSON
import KeychainAccess

@Observable class Authentication {
    var user: User?
    var profile: Profile?
    var attemptingToFetchUser = false
    var loggingIn = false
    var authToken = K.keychain["authToken"]
    
    var authTokenExpiration: Date? {
        guard let expiresAtString = K.keychain["authTokenExpiration"] else { return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.dateFormat
        return dateFormatter.date(from: expiresAtString)
    }
    
    init() {
        do {
            let jsonString = UserDefaults.standard.string(forKey: K.profilePath)
            guard let jsonString else { throw "Can't load profile selection" }
            
            guard let data = jsonString.data(using: .utf8) else { throw "Can't load profile selection" }
            let json = try JSON(data: data)
            let profile = try Profile(from: json)
            withAnimation { self.profile = profile }
        } catch {
            print("🚨 Error loading profile: \(error.localizedDescription)")
        }
    }
}

// MARK: Public methods
extension Authentication {
    @MainActor
    func login(with url: String) async throws {
        guard let _ = URL(string: url) else { throw "Invalid URL Format" }
        let urlComponents = url.components(separatedBy: "/")
        guard let password = urlComponents.last, let username = urlComponents.dropLast().last else {
            throw "Invalid URL Format"
        }
        
        var request = URLRequest(url: URL(string: "\(K.apiURLBase)/login")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let data = try JSONEncoder().encode([
            "username": username,
            "password": password
        ])
        
        let (responseData, _) = try await URLSession.shared.upload(for: request, from: data)
        let json = try JSON(data: responseData)
        let loginResponse = try LoginResponse(from: json)
        
        withAnimation {
            authToken = loginResponse.token
        }
        K.keychain["authToken"] = loginResponse.token
        K.keychain["authTokenExpiration"] = loginResponse.expiresAt.formatted(K.dateFormat)
        
        try await getUser()
    }
    
    @MainActor
    func getUser() async throws {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let url = URL(string: "\(K.apiURLBase)/user")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let user = try User(from: json)
        
        withAnimation { self.user = user }
    }
    
    @MainActor
    func getProfiles() async throws -> [Profile] {
        guard let authToken = K.keychain["authToken"] else { throw "Auth token not found" }
        
        let urlComps = URLComponents(string: "\(K.apiURLBase)/profiles")!
        let url = urlComps.url!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSON(data: responseData)
        let profiles = try json["data"].arrayValue.compactMap { jsonP in
            return try Profile(from: jsonP)
        }
        
        return profiles
    }
    
    @MainActor
    func logout() throws {
        withAnimation {
            user = nil
            profile = nil
            authToken = nil
            attemptingToFetchUser = false
            loggingIn = false
        }
        UserDefaults.standard.removeObject(forKey: K.profilePath)
        try K.keychain.remove("authToken")
        try K.keychain.remove("authTokenExpiration")
    }
}
