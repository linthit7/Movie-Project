//
//  CollectionViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/6/23.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"

    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        movieImage.image = UIImage(named: "one")
        movieTitle.text = "Dummy"
    }
}
