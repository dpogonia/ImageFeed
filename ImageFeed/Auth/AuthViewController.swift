//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 22.05.2026.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - UI
    
    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    private var isAuthorizing = false
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureBackButton()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(resource: .authScreenLogo)
        logoImageView.contentMode = .scaleAspectFit
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.backgroundColor = UIColor(resource: .ypWhite)
        loginButton.setTitleColor(UIColor(resource: .ypBlack), for: .normal)
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        loginButton.accessibilityIdentifier = "Authenticate"
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        view.addSubview(logoImageView)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            loginButton.widthAnchor.constraint(equalToConstant: 343),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        guard !isAuthorizing else { return }
        
        let webViewViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.delegate = self
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        closeWebView(vc)
        
        isAuthorizing = true
        UIBlockingProgressHUD.show()
        
        fetchOAuthToken(code) { [weak self] result in
            self?.isAuthorizing = false
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("[AuthViewController]: \(error)")
                self.showAuthErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        closeWebView(vc)
    }
}

// MARK: - OAuth helpers

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
    
    private func closeWebView(_ vc: WebViewViewController) {
        if let navigationController = vc.navigationController,
           navigationController.viewControllers.first !== vc {
            navigationController.popViewController(animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
