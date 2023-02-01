//
//  LoadingScreen.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/1/23.
//

import UIKit

struct Loading {
    static func accountLoading() -> UIViewController {
        AppDelegate.accountLoadingState = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Loading State"), object: nil)
        let loadingVC = LoadingViewController()
        loadingVC.view.isUserInteractionEnabled = false
        loadingVC.navigationItem.hidesBackButton = true
        return loadingVC
    }
    
}
