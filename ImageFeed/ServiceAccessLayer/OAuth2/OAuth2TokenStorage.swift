//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 26.05.2026.
//

import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Storage
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"

    // MARK: - Token
    
    var token: String? {
        get {
            userDefaults.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                userDefaults.set(newValue, forKey: tokenKey)
            } else {
                userDefaults.removeObject(forKey: tokenKey)
            }
        }
    }
}
