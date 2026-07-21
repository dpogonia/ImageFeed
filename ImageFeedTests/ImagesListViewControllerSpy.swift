//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    private(set) var updatePhotosCalled = false

    func updatePhotos(_ photos: [Photo]) {
        updatePhotosCalled = true
    }
}
