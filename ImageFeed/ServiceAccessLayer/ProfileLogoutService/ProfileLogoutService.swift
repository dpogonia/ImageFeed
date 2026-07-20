//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 09.07.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clearProfileCache()
        ProfileImageService.shared.clearAvatarCache()
        ImagesListService.shared.clearPhotosCache()
        cleanCookies()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
}
