//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 10.05.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private lazy var avatarImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAvatarImage()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }
    
    // MARK: - Setup
    
    private func setupAvatarImage() {
        avatarImageView.image = UIImage(resource: .avatar)
        avatarImageView.clipsToBounds = true
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
        nameLabel.attributedText = NSAttributedString(
            string: "Екатерина Новикова",
            attributes: [
                .font: UIFont.systemFont(ofSize: 23, weight: .bold),
                .foregroundColor: UIColor(resource: .ypWhite),
                .kern: 0.3
            ]
        )
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func setupLoginNameLabel() {
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        paragraphStyle.maximumLineHeight = 18
        
        loginNameLabel.attributedText = NSAttributedString(
            string: "@ekaterina_nov",
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(resource: .ypGray)
            ]
        )
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        paragraphStyle.maximumLineHeight = 18
        
        descriptionLabel.attributedText = NSAttributedString(
            string: "Hello, world!",
            attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(resource: .ypWhite)
            ]
        )
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
    
    @objc private func didTapLogoutButton() { }
    
}
