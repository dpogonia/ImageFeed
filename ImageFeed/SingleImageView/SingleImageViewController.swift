//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 12.05.2026.
//

import Kingfisher
import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame = CGRect(origin: .zero, size: image.size)
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let backButton = UIButton(type: .custom)
    private let shareButton = UIButton(type: .custom)
    private var lastLayoutBoundsSize = CGSize.zero
    
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
        
        scrollView.delegate = self
        
        guard let image else {
            if let imageURL {
                loadImage(from: imageURL)
            }
            return
        }
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let image, scrollView.bounds.size != lastLayoutBoundsSize else { return }
        lastLayoutBoundsSize = scrollView.bounds.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.tintColor = .white
        backButton.accessibilityIdentifier = "nav back button white"
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(
            UIImage(resource: .shareButton).withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            shareButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -17),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func loadImage(from url: URL) {
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            defer { UIBlockingProgressHUD.dismiss() }
            
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: nil,
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self, let imageURL else { return }
            self.loadImage(from: imageURL)
        })
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let visibleRectSize = scrollView.bounds.size
        guard visibleRectSize.width > 0, visibleRectSize.height > 0 else { return }
        
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        let imageSize = image.size
        let widthScale = visibleRectSize.width / imageSize.width
        let heightScale = visibleRectSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = max(3.0 * minScale, 1.25)
        scrollView.zoomScale = minScale
        centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let horizontalInset = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let verticalInset = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
