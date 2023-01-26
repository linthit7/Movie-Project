//
//  MovieInfoTableViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/25/23.
//

import UIKit

class MovieInfoTableViewCell: UITableViewCell {

    static let reuseIdentifier = String(describing: MovieInfoTableViewCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
