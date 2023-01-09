//
//  MovieDetailViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/9/23.
//

import UIKit
import SDWebImage

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieBackDropImage: UIImageView!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var similarMovieCollectionView: UICollectionView!
    
    var movieTitle: String?
    var overView: String?
    var backDropImage: String?
    var releaseDate: String?
    var rating: Float?
    var movieID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMovieDetail()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func insertImage() {
        
        let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(backDropImage!)")
        DispatchQueue.main.async {
            self.movieBackDropImage.sd_setImage(with: backDropImageURL)
        }
    }
    
    private func setUpMovieDetail() {
        
        DispatchQueue.main.async {
            self.title = self.movieTitle
            self.insertImage()
            self.overViewLabel.text = self.overView
            self.releaseDateLabel.text = "Release Date: \(self.releaseDate!)"
            self.ratingLabel.text = "Rating: \(self.rating!) / 10"
            print(self.movieID!)
        }
    }

}
