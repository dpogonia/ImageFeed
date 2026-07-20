//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 20.07.2026.
//

import Foundation

nonisolated protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func removeUserData()
}

nonisolated final class ProfileViewPresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    deinit {
        if let profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(with: profile)
        }
        addObserver()
    }

    func removeUserData() {
        ProfileLogoutService.shared.logout()
        view?.switchToSplashScreen()
    }

    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        view?.updateAvatar(with: url)
    }
}
