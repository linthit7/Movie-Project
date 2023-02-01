//
//  AccountViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/28/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = acc.username
        passwordTextField.text = acc.password
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        navigationController?.pushViewController(Loading.accountLoading(), animated: false)

        do {
            try LoginLogic.checkCredentials(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
        } catch {
            print(error)
        }
    }
    
}
