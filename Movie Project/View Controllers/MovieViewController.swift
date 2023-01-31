//
//  MovieViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/25/23.
//

import UIKit
import CoreData
import SwiftyJSON

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    let request = Request()
    var vc: String!
    var movieDetail: OnlineMovie!
    var movieDetailList: [MovieResult] = []
    var movie: MovieResult!
    var favoriteState: Bool?
    var genreNameArray: [String] = []
    var genreName: String?
    var watchListMovie: Movie!
    var currentMovieID: Int = 0
    var tempMovie: Movie!
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
        
        setupFavoriteButton()
        table.register(UINib(nibName: MovieCollectionTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieCollectionTableViewCell.reuseIdentifier)
        table.register(UINib(nibName: MovieInfoTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieInfoTableViewCell.reuseIdentifier)
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMovieDetail(viewController: vc)

        if watchListMovie != nil {
            MovieLogic.tempData(viewController: vc, movieObject: watchListMovie) { tempObject in

                self.tempMovie = tempObject
                self.tempID = Int(tempObject.movieID)
                self.tempTitle = tempObject.movieTitle
                self.tempBackDrop = tempObject.backDropImage
                self.tempOverview = tempObject.overView
                self.tempReleaseDate = tempObject.releaseDate
                self.tempRating = tempObject.rating as? Float
                self.tempState = tempObject.favoriteState as? Bool
                self.tempPoster = tempObject.posterImage
                self.tempGenre = tempObject.genreName
            }
        }
    }
    
    private func setupFavoriteButton() {
        if AppDelegate.sessionState {
            checkFavoriteState(viewController: vc)
            configureNavItem()
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
        if vc == getVC.favoriteVC {
            Request.updateFavorite(mediaId: tempID, favorite: true, sessionId: AuthLogic.getSession()!) { [weak self] _ in
                self?.moviePersist(viewController: (self?.vc)!)
            }
        } else {
            Request.updateFavorite(mediaId: movie.id, favorite: true, sessionId: AuthLogic.getSession()!) { [weak self] _ in
                self?.moviePersist(viewController: (self?.vc)!)
            }
        }
    }
    
    private func checkFavoriteState(viewController: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        if viewController == getVC.favoriteVC {
            fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(watchListMovie.movieID)")
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
    
    private func moviePersist(viewController: String) {
        
        if viewController == getVC.favoriteVC {
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
                print("movie persisted")
            } catch let error {
                print(error)
            }
        } else {
            switch MovieLogic.fetchAnObject(getMovie: movie) {
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
                    print("movie persisted")
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
        
        if vc == getVC.favoriteVC {
            Request.updateFavorite(mediaId: tempID, favorite: false, sessionId: AuthLogic.getSession()!) { [self] _ in
                MovieLogic.delete(id: vc == getVC.favoriteVC ? Int(tempMovie.movieID) : movie.id!)
            }
        } else {
            Request.updateFavorite(mediaId: movie.id, favorite: false, sessionId: AuthLogic.getSession()!) { [self] _ in
                MovieLogic.delete(id: vc == getVC.favoriteVC ? Int(tempMovie.movieID) : movie.id!)
            }
        }
        
    }
    
    private func setUpMovieDetail(viewController: String) {
        if viewController == getVC.favoriteVC {
            self.currentMovieID = Int(watchListMovie.movieID)
        }
    }
    
    //MARK: - UITableViewDelegate & DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch vc {
        case getVC.favoriteVC: return 1
        default: return 2
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = table.dequeueReusableCell(withIdentifier: MovieInfoTableViewCell.reuseIdentifier, for: indexPath) as? MovieInfoTableViewCell else {
            return UITableViewCell()
        }
            if vc == getVC.favoriteVC {
                currentMovieID = Int(watchListMovie.movieID)
                cell.titleLabel.text = watchListMovie.movieTitle
                cell.descriptionLabel.text = watchListMovie.overView
                cell.dateLabel.text = "Release Date: \(watchListMovie.releaseDate!)"
                cell.ratingLabel.text = "Rating: \(watchListMovie.rating!) / 10"
                cell.genreLabel.text = "Genre: \(self.watchListMovie.genreName!)"
                let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(watchListMovie.backDropImage!)")
                cell.movieImage.sd_setImage(with: backDropImageURL)
            } else {
                cell.titleLabel.text = movie.title
                cell.descriptionLabel.text = movie.overview
                cell.dateLabel.text = "Release Date: \(movie.release_date!)"
//                genreIDArrayConversion(insert: movie.genre_ids)
                if genreNameArray.isEmpty {
                    genreNameArray = MovieLogic.genreIDArrayConversion(insert: movie.genre_ids)
                }
                cell.genreLabel.text = "Similar Movies - \(genreNameArray.joined(separator: ", "))"
                genreName = genreNameArray.joined(separator: ", ")
                cell.ratingLabel.text = "Rating: \(movie.vote_average!) / 10"
                let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(movie.backdrop_path!)")
                cell.movieImage.sd_setImage(with: backDropImageURL)
            }
            return cell
        case 1:
            guard let cell = self.table.dequeueReusableCell(withIdentifier: MovieCollectionTableViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionTableViewCell else {return UITableViewCell()}
            cell.movieDetailList = self.movieDetailList
            return cell
        default: return UITableViewCell()
        }
     }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
