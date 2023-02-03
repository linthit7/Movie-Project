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
        
        movieImage.layer.cornerCurve = .continuous
        movieImage.layer.cornerRadius = 10
    }
    
    func populateWithMovieResult(movie: MovieResult) {
        insertTitle(with: movie.title)
        insertImage(with: movie.poster_path)
    }
    func populateWithMovie(movie: Movie) {
        insertTitle(with: movie.movieTitle!)
        insertImage(with: movie.posterImage!)
    }
    private func insertTitle(with title: String) {
            self.movieTitle.text = title
    }
    private func insertImage(with image: String) {
        let posterImageURL = URL(string: "\(Support.posterImageURL)\(image)")
            self.movieImage.sd_setImage(with: posterImageURL, placeholderImage: UIImage(systemName: "placeholdertext.fill"))
    }
    
}
