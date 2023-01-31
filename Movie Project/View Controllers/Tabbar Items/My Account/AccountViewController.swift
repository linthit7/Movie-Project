//
//  AccountViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/30/23.
//

import UIKit
import SDWebImage

class AccountViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "My Account"
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            Request.getAccountDetail(sessionID: AuthLogic.getSession()!) { [weak self] account in
                self?.profileImageView.sd_setImage(with: URL(string: "\(Support.posterImageURL)\(account.avatar.tmdb.values.first!)"))
                self?.nameLabel.text = account.name
                self?.usernameLabel.text = ("username: \(account.username!)")
                self?.idLabel.text = ("id: \(account.id!)")
            }
        }
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        Request.deleteSession(sessionID: AuthLogic.getSession()!)
    }
}
