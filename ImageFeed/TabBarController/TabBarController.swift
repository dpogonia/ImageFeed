//
//  TabBarController.swift
//  ImageFeed
//
//  Вкладки и внешний вид TabBar настраиваем полностью в коде (задача со звёздочкой).
//

import UIKit

final class TabBarController: UITabBarController {
    
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
        
        configureAppearance()
        
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - Appearance
    
    private func configureAppearance() {
        tabBar.tintColor = UIColor(resource: .ypWhite)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .ypBlack)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
