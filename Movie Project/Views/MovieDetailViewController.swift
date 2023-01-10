//
//  MovieDetailViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/9/23.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieBackDropImage: UIImageView!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var similarMovieCollectionView: UICollectionView!
    
    var favoriteState: Bool = false
    
    var movieTitle: String?
    var overView: String?
    var backDropImage: String?
    var releaseDate: String?
    var rating: Float?
    var movieID: Int?
    var genreID: Any?
    var genreIDArrayCount: Int?
    var genreNameArray: [String] = []
    
    var similarMovieTitleArray: [String] = []
    var similarMoviePosterArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMovieDetail()
        navigationController?.navigationBar.prefersLargeTitles = true
        similarMovieCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        similarMovieCollectionView.delegate = self
        similarMovieCollectionView.dataSource = self
        view.addSubview(similarMovieCollectionView)
        
        configureNavItem()
    }
    
    private func configureNavItem() {
        navigationController?.navigationBar.tintColor = .label
        
        switch favoriteState {
        case false:
            let favoriteItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(favoriteAdd(_:)))
            navigationItem.rightBarButtonItem  = favoriteItem
        case true:
            let favoriteItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(favoriteRemove(_:)))
            navigationItem.rightBarButtonItem  = favoriteItem
        }
    }
    
    @objc private func favoriteAdd(_ sender: UIButton) {
        favoriteState = true
        configureNavItem()
        print("FavoriteItem Add")
        print(favoriteState)
    }
    
    @objc private func favoriteRemove(_ sender: UIButton) {
        favoriteState = false
        configureNavItem()
        print("FavoriteItem Remove")
        print(favoriteState)
    }
    
    private func insertImage() {
        
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
            self.similarRequest()
            self.genreIDArrayConversion(insert: self.genreID!)
            self.genreLabel.text = "Similar Movies - \(self.genreNameArray.joined(separator: ","))"
        }
    }
    
    func genreIDArrayConversion(insert: Any) {
        
        let genreIDArray: Array<JSON> = insert as! Array<JSON>
        self.genreIDArrayCount = genreIDArray.count
        
        for g in 0..<genreIDArrayCount! {
            let genreInt: Int = genreIDArray[g].rawValue as! Int
            genreNameArray.append(Genre(genreID: genreInt).genreName)
        }
    }
    
    //MARK: - Network Request Methods
    
    private func similarRequest() {
        let requestQueue = DispatchQueue(label: "similarRequest", qos: .userInitiated)
        
        let similarURL = "\(Support.baseURL)/movie/\(movieID!)/similar?api_key=\(Support.apiKey)"
        requestQueue.async {
            Alamofire.request(similarURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    let similarJSON: JSON = JSON(response.result.value!)
                    let similarArrayCount = similarJSON["results"].array?.count ?? 0
                    
                    for sim in 0..<similarArrayCount {
                        
                        let title = similarJSON["results"][sim]["title"].stringValue
                        let posterImage = similarJSON["results"][sim]["poster_path"].stringValue
                        
                        self.similarMovieTitleArray.append(title)
                        self.similarMoviePosterArray.append(posterImage)
                        self.similarMovieCollectionView.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }


}



//MARK: - UICollectionView Delegate & DataSource Methods

extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: similarMovieTitleArray[indexPath.row])
        cell.insertImage(with: similarMoviePosterArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: 200)
    }
}

