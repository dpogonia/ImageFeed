//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 07.05.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI
    
    private let cellImageView = UIImageView()
    private let likeButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    
    // MARK: - Private properties
    
    private let dateGradientLayer = CAGradientLayer()
    private let dateGradientHeight: CGFloat = 72
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Config
    
    func configure(image: UIImage?, date: String?, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date
        dateLabel.isHidden = (date == nil)
        
        let likeImage = UIImage(resource: isLiked ? .likeButtonOn : .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
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
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.isUserInteractionEnabled = false
        
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
}
