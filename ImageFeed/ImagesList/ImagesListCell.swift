//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 07.05.2026.
//

import Kingfisher
import UIKit

enum FeedCellImageState {
    case loading
    case error
    case finished(UIImage)
}

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCell(_ cell: ImagesListCell, didFinishLoadingImageWith size: CGSize)
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - UI
    
    let cellImageView = UIImageView()
    private let likeButton = UIButton(type: .custom)
    private let dateLabel = UILabel()
    
    // MARK: - Private properties
    
    private let dateGradientLayer = CAGradientLayer()
    private let dateGradientHeight: CGFloat = 72
    private var imageGradientView: AnimatedGradientView?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        cellImageView.kf.cancelDownloadTask()
        removeImageLoadingAnimation()
        cellImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Config
    
    func configure(with photo: Photo, date: String?) {
        dateLabel.text = date
        dateLabel.isHidden = (date == nil)
        setIsLiked(photo.isLiked)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = UIImage(resource: isLiked ? .likeButtonOn : .likeButtonOff)
            .withRenderingMode(.alwaysOriginal)
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
    
    func setImageState(_ state: FeedCellImageState) {
        switch state {
        case .loading:
            showImageLoadingAnimation()
        case .error:
            removeImageLoadingAnimation()
            cellImageView.image = UIImage(resource: .rectangle)
        case .finished(let image):
            removeImageLoadingAnimation()
            cellImageView.image = image
        }
    }
    
    func configure(image: UIImage?, date: String?, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date
        dateLabel.isHidden = (date == nil)
        setIsLiked(isLiked)
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Private helpers
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.clipsToBounds = true
        cellImageView.layer.cornerRadius = 16
        cellImageView.kf.indicatorType = .activity
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .white
        
        contentView.addSubview(cellImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        
        let layoutGuide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            likeButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            cellImageView.trailingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor, constant: 8)
        ])
    }
    
    private func setupGradient() {
        dateGradientLayer.locations = [0.0, 1.0]
        dateGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        dateGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let baseColor = UIColor(
            red: 26.0 / 255.0,
            green: 27.0 / 255.0,
            blue: 34.0 / 255.0,
            alpha: 1.0
        )
        
        dateGradientLayer.colors = [
            baseColor.withAlphaComponent(0.0).cgColor,
            baseColor.cgColor
        ]
        
        cellImageView.layer.insertSublayer(dateGradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        let bounds = cellImageView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        let height = min(dateGradientHeight, bounds.height)
        dateGradientLayer.frame = CGRect(
            x: 0,
            y: bounds.height - height,
            width: bounds.width,
            height: height
        )
    }
    
    private func showImageLoadingAnimation() {
        guard imageGradientView == nil else { return }
        
        let gradientView = AnimatedGradientView(frame: cellImageView.bounds)
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientView.layer.cornerRadius = cellImageView.layer.cornerRadius
        gradientView.clipsToBounds = true
        cellImageView.addSubview(gradientView)
        gradientView.startAnimating()
        imageGradientView = gradientView
    }
    
    private func removeImageLoadingAnimation() {
        imageGradientView?.stopAnimating()
        imageGradientView = nil
    }
}
