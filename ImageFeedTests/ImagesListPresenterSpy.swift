//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var fetchPhotosNextPageCalled = false
    private(set) var photosDidChangeCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func photosDidChange() {
        photosDidChangeCalled = true
    }
}
