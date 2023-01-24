//
//  MovieInfoViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/23/23.
//

import UIKit
import CoreData
import SwiftyJSON
import SDWebImage

class MovieInfoViewController: UIViewController {
    
    @IBOutlet weak var movieInfoCollectionView: UICollectionView!
    
    let request = Request()
    var vc: String!
    
    var movieDetail: OnlineMovie!
    var movieDetailList: [MovieResult] = []
    var movie: MovieResult!
    var favoriteState: Bool?
    var genreNameArray: [String] = []
    var genreName: String?
    var watchListMovie: NSManagedObject!
    var currentMovieID: Int = 0
    
    var tempMovie: NSManagedObject!
    
    var tempID: Int!
    var tempTitle: String!
    var tempBackDrop: String!
    var tempOverview: String!
    var tempReleaseDate: String!
    var tempRating: Float!
    var tempState: Bool!
    var tempPoster: String!
    var tempGenre: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkFavoriteState(viewController: vc)
        configureNavItem()
        
        movieInfoCollectionView.register(UINib(nibName: MovieInfoCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: MovieInfoCollectionViewCell.reuseIdentifier)
        movieInfoCollectionView.dataSource = self
        movieInfoCollectionView.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMovieDetail(viewController: vc)
        
        if watchListMovie != nil {
            MovieDetailLogic.tempData(viewController: vc, movieObject: watchListMovie) { tempObject in
                self.tempID = tempObject.value(forKey: "movieID") as? Int
                self.tempTitle = tempObject.value(forKey: "movieTitle") as? String
                self.tempBackDrop = tempObject.value(forKey: "backDropImage") as? String
                self.tempOverview = tempObject.value(forKey: "overView") as? String
                self.tempReleaseDate = tempObject.value(forKey: "releaseDate") as? String
                self.tempRating = tempObject.value(forKey: "rating") as? Float
                self.tempState = tempObject.value(forKey: "favoriteState") as? Bool
                self.tempPoster = tempObject.value(forKey: "posterImage") as? String
                self.tempGenre = tempObject.value(forKey: "genreName") as? String
            }
        }
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
        default: return
        }
    }
    
    @objc private func favoriteAdd(_ sender: UIButton) {
        favoriteState = true
        configureNavItem()
        moviePersist(viewController: vc)
    }
    
    private func checkFavoriteState(viewController: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        if viewController == "WatchlistViewController" {
            fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(watchListMovie.value(forKey: "movieID")!)")
        } else {
            fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(movie.id!)")
        }
        do {
            let object = try managedContext.fetch(fetchRequest)
            if object.isEmpty {
                favoriteState = false
            } else {
                favoriteState = true
            }
        } catch let error {
            print(error)
        }
    }
    
    private func fetchAnObject() -> Bool? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(movie.id!)")
        do {
            let object = try managedContext.fetch(fetchRequest)
            if object.isEmpty {return true} else {return false}
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func moviePersist(viewController: String) {
        
        if viewController == "WatchlistViewController" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let movieEntity = NSEntityDescription.entity(forEntityName: "Movie", in: managedContext) else {return}
            let nsMovie = NSManagedObject(entity: movieEntity, insertInto: managedContext)
            
            nsMovie.setValue(tempID, forKey: "movieID")
            nsMovie.setValue(tempTitle, forKey: "movieTitle")
            nsMovie.setValue(tempBackDrop, forKey: "backDropImage")
            nsMovie.setValue(tempOverview, forKey: "overView")
            nsMovie.setValue(tempReleaseDate, forKey: "releaseDate")
            nsMovie.setValue(tempRating, forKey: "rating")
            nsMovie.setValue(tempState, forKey: "favoriteState")
            nsMovie.setValue(tempPoster, forKey: "posterImage")
            nsMovie.setValue(tempGenre, forKey: "genreName")
            do {
                try managedContext.save()
            } catch let error {
                print(error)
            }
        } else {
            switch fetchAnObject() {
            case true:
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                let managedContext = appDelegate.persistentContainer.viewContext
                guard let movieEntity = NSEntityDescription.entity(forEntityName: "Movie", in: managedContext) else {return}
                let nsMovie = NSManagedObject(entity: movieEntity, insertInto: managedContext)
                nsMovie.setValue(movie.id, forKey: "movieID")
                nsMovie.setValue(movie.title, forKey: "movieTitle")
                nsMovie.setValue(movie.backdrop_path, forKey: "backDropImage")
                nsMovie.setValue(movie.overview, forKey: "overView")
                nsMovie.setValue(movie.release_date, forKey: "releaseDate")
                nsMovie.setValue(movie.vote_average, forKey: "rating")
                nsMovie.setValue(favoriteState, forKey: "favoriteState")
                nsMovie.setValue(movie.poster_path, forKey: "posterImage")
                nsMovie.setValue(genreName, forKey: "genreName")
                do {
                    try managedContext.save()
                } catch let error {
                    print(error)
                }
            case false: return print("Object found")
            default: return
            }
        }
    }
    
    @objc private func favoriteRemove(_ sender: UIButton) {
        favoriteState = false
        configureNavItem()
        movieDelete(viewController: vc)
    }
    
    private func movieDelete(viewController: String) {
        if viewController == "WatchlistViewController" {
            MovieDetailLogic.delete(id: tempID!)
        } else {
            MovieDetailLogic.delete(id: movie.id!)
        }
    }
    
    private func setUpMovieDetail(viewController: String) {
        if viewController == "WatchlistViewController" {
            self.currentMovieID = self.watchListMovie.value(forKey: "movieID") as! Int
        }
    }
    
    func genreIDArrayConversion(insert intArray: [JSON]) {
        for g in 0..<intArray.count {
            let genreInt: Int = intArray[g].rawValue as! Int
            genreNameArray.append(Genre(genreID: genreInt).genreName)
        }
    }
    
    
    
}

//MARK: - MovieInfo UICollectionViewDataSource & Delegate
extension MovieInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = movieInfoCollectionView.dequeueReusableCell(withReuseIdentifier: MovieInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieInfoCollectionViewCell else {
            return UICollectionViewCell()
        }
        if vc == "WatchlistViewController" {
            self.currentMovieID = self.watchListMovie.value(forKey: "movieID") as! Int
            cell.titleLabel.text = self.watchListMovie.value(forKey: "movieTitle") as? String
            cell.descriptionTextView.text = self.watchListMovie.value(forKey: "overView") as? String
            cell.dateLabel.text = "Release Date: \(self.watchListMovie.value(forKey: "releaseDate")!)"
            cell.ratingLabel.text = "Rating: \(self.watchListMovie.value(forKey: "rating")!) / 10"
            cell.genreLabel.text = "\(self.watchListMovie.value(forKey: "genreName")!)"
            let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(watchListMovie.value(forKey: "backDropImage")!)")
            cell.movieImage.sd_setImage(with: backDropImageURL)
        } else {
            cell.titleLabel.text = self.movie.title
            cell.descriptionTextView.text = self.movie.overview
            cell.dateLabel.text = "Release Date: \(self.movie.release_date!)"
            self.genreIDArrayConversion(insert: self.movie.genre_ids)
            cell.genreLabel.text = "Similar Movies - \(self.genreNameArray.joined(separator: ","))"
            self.genreName = self.genreNameArray.joined(separator: ",")
            cell.ratingLabel.text = "Rating: \(self.movie.vote_average!) / 10"
            let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(movie.backdrop_path!)")
            cell.movieImage.sd_setImage(with: backDropImageURL)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
}

