//
//  Photo.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 25.06.2026.
//

import CoreGraphics
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
    
    func withSize(_ size: CGSize) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            fullImageURL: fullImageURL,
            isLiked: isLiked
        )
    }
    
    func withIsLiked(_ isLiked: Bool) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            fullImageURL: fullImageURL,
            isLiked: isLiked
        )
    }
}
