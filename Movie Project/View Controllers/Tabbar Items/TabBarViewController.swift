//
//  TabBarViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.setUpTabBar()
    }
    
    private func setUpTabBar() {
        
        let popularVC = UINavigationController(rootViewController: PopularViewController())
        let lastestVC = UINavigationController(rootViewController: UpcomingViewController())
        let favoriteVC = UINavigationController(rootViewController: FavoriteViewController())
        let accountVC = UINavigationController(rootViewController: AppDelegate.sessionState ? AccountViewController() : LoginViewController() )
        
        popularVC.tabBarItem.image = UIImage(systemName: "10.square.fill")
        lastestVC.tabBarItem.image = UIImage(systemName: "arrow.up.square.fill")
        favoriteVC.tabBarItem.image = UIImage(systemName: "star.fill")
        accountVC.tabBarItem.image = UIImage(systemName: "person.crop.square")
        
        popularVC.title = "Popular Movies"
        lastestVC.title = "Upcoming Movies"
        favoriteVC.title = "Favorite Movies"
        accountVC.title = "My Account"
        
        tabBar.tintColor = .label
        setViewControllers([popularVC, lastestVC, favoriteVC, accountVC], animated: true)
    }
    
}
