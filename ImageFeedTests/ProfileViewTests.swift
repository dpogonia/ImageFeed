//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {

    @MainActor
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    @MainActor
    func testViewControllerCallsRemoveUserData() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        presenter.removeUserData()

        XCTAssertTrue(presenter.removeUserDataCalled)
    }
}
