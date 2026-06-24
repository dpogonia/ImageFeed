//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 10.05.2026.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var avatarImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var logoutButton = UIButton()
    
    // MARK: - Services
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAvatarImage()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }
    
    deinit {
        if let profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }
    
    // MARK: - Profile UI
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageURL = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageURL,
            placeholder: UIImage(resource: .avatar),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { result in
            if case .failure(let error) = result {
                print("[updateAvatar]: \(error)")
            }
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        nameLabel.attributedText = NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.systemFont(ofSize: 23, weight: .bold),
                .foregroundColor: UIColor(resource: .ypWhite),
                .kern: 0.3
            ]
        )
        
        let loginName = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        let loginFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let loginParagraphStyle = NSMutableParagraphStyle()
        loginParagraphStyle.minimumLineHeight = 18
        loginParagraphStyle.maximumLineHeight = 18
        
        loginNameLabel.attributedText = NSAttributedString(
            string: loginName,
            attributes: [
                .font: loginFont,
                .paragraphStyle: loginParagraphStyle,
                .foregroundColor: UIColor(resource: .ypGray)
            ]
        )
        
        let bio: String
        if let profileBio = profile.bio, !profileBio.isEmpty {
            bio = profileBio
        } else {
            bio = "Профиль не заполнен"
        }
        let bioFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let bioParagraphStyle = NSMutableParagraphStyle()
        bioParagraphStyle.minimumLineHeight = 18
        bioParagraphStyle.maximumLineHeight = 18
        
        descriptionLabel.attributedText = NSAttributedString(
            string: bio,
            attributes: [
                .font: bioFont,
                .paragraphStyle: bioParagraphStyle,
                .foregroundColor: UIColor(resource: .ypWhite)
            ]
        )
    }
    
    // MARK: - Setup
    
    private func setupAvatarImage() {
        avatarImageView.image = UIImage(resource: .avatar)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func setupLogoutButton() {
        let image = UIImage(resource: .logoutButton)
        logoutButton.setImage(image, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        showLogoutConfirmationAlert()
    }
    
    private func showLogoutConfirmationAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        avatarImageView.kf.cancelDownloadTask()
        
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clearProfileCache()
        ProfileImageService.shared.clearAvatarCache()
        switchToSplashScreen()
    }
    
    private func switchToSplashScreen() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
}
