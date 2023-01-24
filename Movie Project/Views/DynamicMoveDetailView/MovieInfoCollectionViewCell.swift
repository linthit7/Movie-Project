//
//  CollectionViewCell.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/23/23.
//

import UIKit
import CoreData

class MovieInfoCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: MovieInfoCollectionViewCell.self)
    private let isSeeMore: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
