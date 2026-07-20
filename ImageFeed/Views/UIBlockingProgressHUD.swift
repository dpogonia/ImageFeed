//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Dmitrii Pogonia on 23.06.2026.
//

import UIKit
import ProgressHUD

// MARK: - UIBlockingProgressHUD

final class UIBlockingProgressHUD {
    
    // MARK: - Private
    
    private static var showCount = 0
    
    private static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
    
    // MARK: - Public API
    
    static func show() {
        showCount += 1
        guard showCount == 1 else { return }
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        guard showCount > 0 else { return }
        showCount -= 1
        guard showCount == 0 else { return }
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
