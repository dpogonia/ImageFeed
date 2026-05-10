//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 30.04.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView?
    
    // MARK: - Constants
    
    private enum Constants {
        static let rowHeight: CGFloat = 200
        static let tableViewTopInset: CGFloat = 12
        static let tableViewBottomInset: CGFloat = 12
    }
    
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.rowHeight = Constants.rowHeight
        tableView?.contentInset = UIEdgeInsets(
            top: Constants.tableViewTopInset,
            left: 0,
            bottom: Constants.tableViewBottomInset,
            right: 0
        )
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.configure(
            image: UIImage(named: photosName[indexPath.row]),
            date: dateFormatter.string(from: Date()),
            isLiked: indexPath.row % 2 == 0
        )
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard image.size.width > 0 else { return 0 }
        let scale = imageViewWidth / image.size.width
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
