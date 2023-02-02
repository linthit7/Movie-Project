//
//  ProfileTableViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/2/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var seeYourProfileLabel: UILabel!
    
    static let reuseIdentifier = String(describing: ProfileTableViewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        profileImageView?.layer.cornerRadius = (profileImageView?.frame.size.width ?? 0.0) / 2
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.borderWidth = 0.5
        profileImageView?.layer.borderColor = UIColor.black.cgColor
    }

    
}
