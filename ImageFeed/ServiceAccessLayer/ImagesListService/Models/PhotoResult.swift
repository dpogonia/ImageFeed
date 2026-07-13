//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 25.06.2026.
//

import Foundation

struct UrlsResult: Codable {
    let thumb: String
    let full: String
    let regular: String
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
