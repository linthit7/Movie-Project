//
//  TabbarLogic.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/31/23.
//

import Foundation
import UIKit

struct Tabbar {
    static func setUpTabbar() -> [UINavigationController] {
        let popularVC = UINavigationController(rootViewController: PopularViewController())
        let lastestVC = UINavigationController(rootViewController: UpcomingViewController())
        let favoriteVC = UINavigationController(rootViewController: FavoriteViewController())
        let accountVC = UINavigationController(rootViewController: AppDelegate.sessionState ? SettingsViewController() : LoginViewController())
        popularVC.tabBarItem.image = UIImage(systemName: "10.square.fill")
        lastestVC.tabBarItem.image = UIImage(systemName: "arrow.up.square.fill")
        favoriteVC.tabBarItem.image = UIImage(systemName: "star.fill")
        accountVC.tabBarItem.image = UIImage(systemName: "person.crop.square")
        popularVC.title = "Popular"
        lastestVC.title = "Upcoming"
        favoriteVC.title = "Favorite"
        accountVC.title = AppDelegate.sessionState ? "Settings" : "Login"
        return [popularVC, lastestVC, favoriteVC, accountVC]
    }
    
    
}
