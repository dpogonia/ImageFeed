//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 22.05.2026.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - UI
    
    private let webView = WKWebView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
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
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: []
        ) { [weak self] _, _ in
            self?.updateProgress()
        }
        
        loadAuthView()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor(resource: .ypWhite)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(resource: .ypBlack)
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Progress updates
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: - Auth page loading
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else { return }
       
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else { return }
        
        webView.load(URLRequest(url: url))
        updateProgress()
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
    
// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
