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
import CoreData

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieBackDropImage: UIImageView!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var similarMovieCollectionView: UICollectionView!
    
    let request = Request()
    let cRUD = CRUD()
    
    var vc: String!
    
    var movieDetail: OnlineMovie!
    var movieDetailList: [MovieResult] = []
    var movie: MovieResult!
    var favoriteState: Bool?
    var genreNameArray: [String] = []
    var genreName: String?
    var watchListMovie: NSManagedObject!
    var currentMovieID: Int = 0
    
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
        
        setUpMovieDetail(viewController: vc)
        navigationController?.navigationBar.prefersLargeTitles = true
        similarMovieCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        similarMovieCollectionView.delegate = self
        similarMovieCollectionView.dataSource = self
        view.addSubview(similarMovieCollectionView)
        checkFavoriteState(viewController: vc)
        configureNavItem()
        tempData(viewController: vc)
        
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setUpMovieDetail(viewController: vc)
//        print("View did appear", movieDetailList.count)
//    }
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
    
    private func tempData(viewController: String) {
        if viewController == "WatchlistViewController" {
            tempID = watchListMovie.value(forKey: "movieID") as? Int
            tempTitle = watchListMovie.value(forKey: "movieTitle") as? String
            tempBackDrop = watchListMovie.value(forKey: "backDropImage") as? String
            tempOverview = watchListMovie.value(forKey: "overView") as? String
            tempReleaseDate = watchListMovie.value(forKey: "releaseDate") as? String
            tempRating = watchListMovie.value(forKey: "rating") as? Float
            tempState = watchListMovie.value(forKey: "favoriteState") as? Bool
            tempPoster = watchListMovie.value(forKey: "posterImage") as? String
            tempGenre = watchListMovie.value(forKey: "genreName") as? String
        }
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
            cRUD.delete(id: tempID!)
        } else {
            cRUD.delete(id: movie.id!)
        }
    }

    private func insertImage(viewController: String) {
        
        if viewController == "WatchlistViewController" {
            let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(watchListMovie.value(forKey: "backDropImage")!)")
            DispatchQueue.main.async {
                self.movieBackDropImage.sd_setImage(with: backDropImageURL)
            }
        }
        else {
            let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(movie.backdrop_path!)")
            DispatchQueue.main.async {
                self.movieBackDropImage.sd_setImage(with: backDropImageURL)
            }
        }
    }
    
    private func setUpMovieDetail(viewController: String) {
        if viewController == "WatchlistViewController" {
            DispatchQueue.main.async {
                self.currentMovieID = self.watchListMovie.value(forKey: "movieID") as! Int
                self.title = self.watchListMovie.value(forKey: "movieTitle") as? String
                self.insertImage(viewController: viewController)
                self.overViewLabel.text = self.watchListMovie.value(forKey: "overView") as? String
                self.releaseDateLabel.text = "Release Date: \(self.watchListMovie.value(forKey: "releaseDate")!)"
                self.ratingLabel.text = "Rating: \(self.watchListMovie.value(forKey: "rating")!) / 10"
                self.genreLabel.text = "\(self.watchListMovie.value(forKey: "genreName")!)"
            }
        } else {
            request.movieRequest(url: "SimilarVC", id: movie.id!) { movieResult, _, _ in
                self.movieDetailList.append(contentsOf: movieResult)
                DispatchQueue.main.async {
                    self.similarMovieCollectionView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.title = self.movie.title
                self.insertImage(viewController: viewController)
                self.overViewLabel.text = self.movie.overview
                self.releaseDateLabel.text = "Release Date: \(self.movie.release_date!)"
                self.ratingLabel.text = "Rating: \(self.movie.vote_average!) / 10"
                self.genreIDArrayConversion(insert: self.movie.genre_ids)
                self.genreLabel.text = "Similar Movies - \(self.genreNameArray.joined(separator: ","))"
                self.genreName = self.genreNameArray.joined(separator: ",")
            }
        }
    }
    
    func genreIDArrayConversion(insert intArray: [JSON]) {
        for g in 0..<intArray.count {
            let genreInt: Int = intArray[g].rawValue as! Int
            genreNameArray.append(Genre(genreID: genreInt).genreName)
        }
    }
}

//MARK: - UICollectionView Delegate & DataSource Methods

extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieDetailList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: movieDetailList[indexPath.row].title)
        cell.insertImage(with: movieDetailList[indexPath.row].poster_path)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: 200)
    }
}

