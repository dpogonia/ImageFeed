//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 26.05.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private var imageView: UIImageView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI (верстка кодом)
    
    private func setupImageView() {
        guard imageView == nil else { return }
        
        let splashLogo = UIImage(named: "splash_screen_logo")
        
        let imageView = UIImageView(image: splashLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        self.imageView = imageView
    }
    
    // MARK: - Navigation
    
    private func presentAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = TabBarController()
    }
    
    // MARK: - Profile loading
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    if case .failure(let error) = result {
                        print("[SplashViewController] Profile image fetch failed: \(error)")
                    }
                }
                self.switchToTabBarController()
                
            case .failure(let error):
                print("[SplashViewController] Profile fetch failed: \(error)")
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        (vc.navigationController ?? vc).dismiss(animated: true)
        
        guard let token = storage.token else {
            print("[SplashViewController] OAuth token is missing after authentication")
            return
        }
        
        fetchProfile(token: token)
    }
}
