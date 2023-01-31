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
        tabBar.tintColor = .label
        
        setViewControllers(Tabbar.setUpTabbar(), animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(setupSessionState), name: Notification.Name("Session state"), object: nil)
    }
    
    @objc private func setupSessionState(){
        if AppDelegate.sessionState {
            setViewControllers(Tabbar.setUpTabbar(), animated: true)
            print("login successful")
        } else {
            setViewControllers(Tabbar.setUpTabbar(), animated: true)
            print("logout successful")
        }
    }

}
