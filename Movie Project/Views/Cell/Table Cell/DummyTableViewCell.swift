//
//  DummyTableViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 2/2/23.
//

import UIKit

class DummyTableViewCell: UITableViewCell {

    static let reuseIdentifier = String(describing: DummyTableViewCell.self)
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = "Dummy Label"
        self.selectionStyle = .none
    }
}
