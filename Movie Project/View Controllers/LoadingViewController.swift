//
//  LoadingViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/1/23.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner()
    }
    
    private func showSpinner() {
        activityIndicator.startAnimating()
    }
}
