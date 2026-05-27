//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 07.05.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Outlets
    
    @IBOutlet weak var cellImage: UIImageView?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var dateLabel: UILabel?
    
    // MARK: - Private properties
    
    private let dateGradientLayer = CAGradientLayer()
    private let dateGradientHeight: CGFloat = 72
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Config
    
    func configure(image: UIImage?, date: String?, isLiked: Bool) {
        cellImage?.image = image
        
        dateLabel?.text = date
        dateLabel?.isHidden = (date == nil)
        
        let likeImage = UIImage(resource: isLiked ? .likeButtonOn : .likeButtonOff)
        likeButton?.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Private helpers
    
    private func setupGradient() {
        dateGradientLayer.locations = [0.0, 1.0]
        dateGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        dateGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        let baseColor = UIColor(
            red:   26.0 / 255.0,
            green: 27.0 / 255.0,
            blue:  34.0 / 255.0,
            alpha: 1.0
        )
        
        dateGradientLayer.colors = [
            baseColor.withAlphaComponent(0.0).cgColor,
            baseColor.cgColor
        ]
        
        cellImage?.layer.insertSublayer(dateGradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        guard let bounds = cellImage?.bounds else { return }
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
