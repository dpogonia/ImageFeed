//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {

    @MainActor
    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdatePhotos() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.photosDidChange()

        XCTAssertTrue(viewController.updatePhotosCalled)
    }
}
