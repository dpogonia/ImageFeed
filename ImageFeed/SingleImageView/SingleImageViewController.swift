//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 12.05.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let backButton = UIButton(type: .custom)
    private let shareButton = UIButton(type: .custom)
    
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
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.tintColor = .white
        
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
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
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
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
}
