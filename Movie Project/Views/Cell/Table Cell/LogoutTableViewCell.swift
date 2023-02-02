//
//  LogoutTableViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/2/23.
//

import UIKit
import Toast_Swift

class LogoutTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: LogoutTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        SettingsNotification.post()
        AppDelegate.accountLoadingState = true
        Request.deleteSession(sessionID: AuthLogic.getSession()!)
    }
    
}
