//
//  AccountViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/28/23.
//

import UIKit
import Toast_Swift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = acc.username
        passwordTextField.text = acc.password
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        AppDelegate.accountLoadingState = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: noti.loadingState), object: nil)
        self.view.makeToastActivity(.center)
        do {
            try LoginLogic.checkCredentials(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
        } catch {
            print(error)
        }
    }
    
}
