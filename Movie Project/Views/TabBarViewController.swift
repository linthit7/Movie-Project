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
        
        self.setUpNavBar()
    }
    
    private func setUpNavBar() {
        
        let popularVC = UINavigationController(rootViewController: PopularViewController())
        let lastestVC = UINavigationController(rootViewController: UpcomingViewController())
        let favoriteVC = UINavigationController(rootViewController: WatchlistViewController())
        
        popularVC.tabBarItem.image = UIImage(systemName: "10.square.fill")
        lastestVC.tabBarItem.image = UIImage(systemName: "arrow.up.square.fill")
        favoriteVC.tabBarItem.image = UIImage(systemName:
            "star.fill")
        
        popularVC.title = "Popular Movies"
        lastestVC.title = "Upcoming Movies"
        favoriteVC.title = "Watch List"
        
        tabBar.tintColor = .label
        setViewControllers([popularVC, lastestVC, favoriteVC], animated: true)
    }




}
