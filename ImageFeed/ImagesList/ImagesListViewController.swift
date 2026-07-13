//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 30.04.2026.
//

import Kingfisher
import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let tableViewTopInset: CGFloat = 12
        static let tableViewBottomInset: CGFloat = 12
    }
    
    // MARK: - UI
    
    private let tableView = UITableView()
    
    // MARK: - Data
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupTableView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imagesListDidChange),
            name: ImagesListService.didChangeNotification,
            object: imagesListService
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(
            top: Constants.tableViewTopInset,
            left: 0,
            bottom: Constants.tableViewBottomInset,
            right: 0
        )
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showSingleImage(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.fullImageURL) else { return }
        
        let viewController = SingleImageViewController()
        viewController.imageURL = imageURL
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    @objc private func imagesListDidChange() {
        updateTableViewAnimated()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        let date = photo.createdAt.map { dateFormatter.string(from: $0) }
        
        cell.delegate = self
        cell.configure(with: photo, date: date)
        cell.setImageState(.loading)
        
        if let url = URL(string: photo.largeImageURL) {
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let scale = UIScreen.main.scale
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: imageViewWidth * scale, height: imageViewWidth * scale)
            )
            
            cell.cellImageView.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .rectangle),
                options: [
                    .processor(processor),
                    .scaleFactor(scale),
                    .cacheOriginalImage
                ]
            ) { [weak self, weak cell] result in
                guard let self, let cell else { return }
                switch result {
                case .success(let imageResult):
                    cell.setImageState(.finished(imageResult.image))
                    self.imagesListCell(cell, didFinishLoadingImageWith: imageResult.image.size)
                case .failure:
                    cell.setImageState(.error)
                }
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard photo.size.width > 0 else { return 0 }
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCell(_ cell: ImagesListCell, didFinishLoadingImageWith size: CGSize) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let currentSize = photos[indexPath.row].size
        guard currentSize != size else { return }
        
        imagesListService.setPhotoSize(at: indexPath.row, size: size)
        photos = photos.withReplaced(itemAt: indexPath.row, newValue: photos[indexPath.row].withSize(size))
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            defer { UIBlockingProgressHUD.dismiss() }
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure:
                self.showLikeError()
            }
        }
    }
    
    private func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
