//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 10.05.2026.
//

import UIKit
import Kingfisher

nonisolated protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(with profile: Profile)
    func updateAvatar(with url: URL)
    func switchToSplashScreen()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Views
    
    private lazy var avatarImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var logoutButton = UIButton()
    
    // MARK: - Properties
    
    var presenter: ProfilePresenterProtocol?
    private var animationGradientViews: [AnimatedGradientView] = []
    
    // MARK: - Configuration
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        setupAvatarImage()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        
        if presenter == nil {
            configure(ProfileViewPresenter())
        }
        
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingAnimationIfNeeded()
    }
    
    // MARK: - ProfileViewControllerProtocol
    
    func updateProfileDetails(with profile: Profile) {
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
        
        removeAnimationLayers()
    }
    
    func updateAvatar(with url: URL) {
        showLoadingAnimationIfNeeded()
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .avatar),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            switch result {
            case .success:
                self?.removeAnimationLayers()
            case .failure(let error):
                print("[updateAvatar]: \(error)")
                self?.removeAnimationLayers()
            }
        }
    }
    
    func switchToSplashScreen() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
    
    // MARK: - Animations
    
    private func showLoadingAnimationIfNeeded() {
        guard animationGradientViews.isEmpty else { return }
        
        let hasAvatar = ProfileImageService.shared.avatarURL != nil
            && avatarImageView.image != nil
            && avatarImageView.image != UIImage(resource: .avatar)
        
        if !hasAvatar {
            addAnimatedGradient(to: avatarImageView, cornerRadius: 35)
        }
        
        if ProfileService.shared.profile == nil {
            addAnimatedGradient(to: nameLabel)
            addAnimatedGradient(to: loginNameLabel)
            addAnimatedGradient(to: descriptionLabel)
        }
    }
    
    private func addAnimatedGradient(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradientView = AnimatedGradientView(frame: view.bounds)
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientView.layer.cornerRadius = cornerRadius
        gradientView.clipsToBounds = true
        view.addSubview(gradientView)
        gradientView.startAnimating()
        animationGradientViews.append(gradientView)
    }
    
    private func removeAnimationLayers() {
        animationGradientViews.forEach { $0.stopAnimating() }
        animationGradientViews.removeAll()
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
        let image = UIImage(resource: .logoutButton).withRenderingMode(.alwaysOriginal)
        logoutButton.setImage(image, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.accessibilityIdentifier = "logout button"
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
        presenter?.removeUserData()
    }
}
