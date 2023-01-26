//
//  CollectionViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/6/23.
//

import UIKit
import SDWebImage

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"

    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        movieImage.layer.cornerCurve = .continuous
        movieImage.layer.cornerRadius = 10
        
    }
    
    func insertTitle(with title: String) {
        DispatchQueue.main.async {
            self.movieTitle.text = title
        }
    }
    
    func insertImage(with image: String) {
        let posterImageURL = URL(string: "\(Support.posterImageURL)\(image)")
        DispatchQueue.main.async {
            
            self.movieImage.sd_setImage(with: posterImageURL)
        }
    }
    
}
