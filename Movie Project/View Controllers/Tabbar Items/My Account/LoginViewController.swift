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

        NotificationCenter.default.addObserver(self, selector: #selector(wrongCredentials), name: NSNotification.Name(rawValue: noti.loginState), object: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        view.endEditing(true)
        do {
            AppDelegate.accountLoadingState = true
            try LoginLogic.checkCredentials(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
            self.view.makeToastActivity(.center)
        } catch let (error) {
            if error as! LoginError == LoginError.wrongCredentials {
                LoginNotification.post()
            }
        }
    }
    
    @objc
    private func wrongCredentials() {
        self.view.makeToast("Wrong Credentials", duration: 0.5, position: .top)
        usernameTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
}
