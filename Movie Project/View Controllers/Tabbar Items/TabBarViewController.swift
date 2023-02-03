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
        NotificationCenter.default.addObserver(self, selector: #selector(setupSessionState(_:)), name: Notification.Name(noti.sessionState), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorMessage(_:)), name: Notification.Name(noti.authState), object: nil)
    }
    
    @objc
    private func setupSessionState(_ notification: NSNotification) {
        setViewControllers(Tabbar.setUpTabbar(), animated: false)
        tabBar.isUserInteractionEnabled = true
        if let message = notification.userInfo?["accountMessage"] as? String {
            view.makeToast(message, duration: 1, position: .top)
        }
    }
    
    @objc
    private func errorMessage(_ notification: NSNotification) {
        print("Making Toast")
        if let message = notification.userInfo?["errorMessage"] as? String {
            view.makeToast(message, duration: 1, position: .top)
        }
    }
    
}
