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
        tabBar.tintColor = .label
        
        setViewControllers(Tabbar.setUpTabbar(), animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(setupSessionState), name: Notification.Name(noti.sessionState), object: nil)
    }
    
    @objc
    private func setupSessionState() {
        if AppDelegate.sessionState {
            setViewControllers(Tabbar.setUpTabbar(), animated: false)
            tabBar.isUserInteractionEnabled = true
            self.view.makeToast("Login Succeed", duration: 1, position: .bottom)
            print("login successful")
        } else {
            setViewControllers(Tabbar.setUpTabbar(), animated: false)
            tabBar.isUserInteractionEnabled = true
            self.view.makeToast("Logout Succeed", duration: 1, position: .bottom)
            print("logout successful")
        }
    }

}
