//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var removeUserDataCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func removeUserData() {
        removeUserDataCalled = true
    }
}
