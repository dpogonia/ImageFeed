//
//  AnimatedGradientView.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 09.07.2026.
//

import UIKit

final class AnimatedGradientView: UIView {
    
    // MARK: - Private properties
    
    private let gradientLayer = CAGradientLayer()
    private let animationKey = "locationsChange"
    
    private static let locationsFrom: [NSNumber] = [0, 0.1, 0.3]
    private static let locationsTo: [NSNumber] = [0, 0.8, 1]
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
    
    // MARK: - Public API
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = Self.locationsFrom
        animation.toValue = Self.locationsTo
        gradientLayer.add(animation, forKey: animationKey)
    }
    
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: animationKey)
        removeFromSuperview()
    }
    
    // MARK: - Private helpers
    
    private func setupGradient() {
        isUserInteractionEnabled = false
        
        gradientLayer.locations = Self.locationsFrom
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.masksToBounds = true
        
        layer.addSublayer(gradientLayer)
    }
}
