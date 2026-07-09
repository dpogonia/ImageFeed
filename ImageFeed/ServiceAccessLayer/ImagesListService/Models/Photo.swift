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
    var size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}
