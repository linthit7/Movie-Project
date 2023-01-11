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
    
    var getVC: String?
    
    var favoriteState: Bool?
    var movieTitle: String?
    var overView: String?
    var backDropImage: String?
    var releaseDate: String?
    var rating: Float?
    var movieID: Int?
    var genreID: Any?
    var genreIDArrayCount: Int?
    var genreNameArray: [String] = []
    var posterImage: String?
    var genreName: String?
    
    var similarMovieTitleArray: [String] = []
    var similarMoviePosterArray: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpMovieDetail(viewController: getVC!)
        navigationController?.navigationBar.prefersLargeTitles = true
        similarMovieCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        similarMovieCollectionView.delegate = self
        similarMovieCollectionView.dataSource = self
        view.addSubview(similarMovieCollectionView)
        checkFavoriteState()
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
        default: return
        }
    }
    
    @objc private func favoriteAdd(_ sender: UIButton) {
        favoriteState = true
        configureNavItem()
        moviePersist()
    }
    
    private func checkFavoriteState() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(self.movieID!)")
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
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(self.movieID!)")
        do {
            let object = try managedContext.fetch(fetchRequest)
            if object.isEmpty {return true} else {return false}
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func moviePersist() {
        switch fetchAnObject() {
        case true:
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            
            guard let movieEntity = NSEntityDescription.entity(forEntityName: "Movie", in: managedContext) else {return}
            let movie = NSManagedObject(entity: movieEntity, insertInto: managedContext)
            movie.setValue(movieID, forKey: "movieID")
            movie.setValue(movieTitle, forKey: "movieTitle")
            movie.setValue(backDropImage, forKey: "backDropImage")
            movie.setValue(overView, forKey: "overView")
            movie.setValue(releaseDate, forKey: "releaseDate")
            movie.setValue(rating, forKey: "rating")
            movie.setValue(favoriteState, forKey: "favoriteState")
            movie.setValue(posterImage, forKey: "posterImage")
            movie.setValue(genreName, forKey: "genreName")
            do {
                try managedContext.save()
                print("Data saved")
            } catch let error {
                print(error)
            }
        case false: return print("Object found")
        default: return
        }
        
    }
    
    @objc private func favoriteRemove(_ sender: UIButton) {
        favoriteState = false
        configureNavItem()
        movieDelete()
    }
    
    private func movieDelete() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "movieID = %@", "\(self.movieID!)")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else {return}
            
            guard let movie = result.first else {return}
            managedContext.delete(movie)
            do {
                try managedContext.save()
                print("Movie Deleted")
            }
        } catch let error {
            print(error)
        }
    }
    
    private func insertImage() {
        let backDropImageURL = URL(string: "\(Support.backDropImageURL)\(backDropImage!)")
        DispatchQueue.main.async {
            self.movieBackDropImage.sd_setImage(with: backDropImageURL)
        }
    }
    
    private func setUpMovieDetail(viewController: String) {
        if viewController == "WatchlistViewController" {
            DispatchQueue.main.async {
                self.title = self.movieTitle
                self.insertImage()
                self.overViewLabel.text = self.overView
                self.releaseDateLabel.text = "Release Date: \(self.releaseDate!)"
                self.ratingLabel.text = "Rating: \(self.rating!) / 10"
                self.genreLabel.text = "\(self.genreName!)"
            }
        } else {
            DispatchQueue.main.async {
                self.title = self.movieTitle
                self.insertImage()
                self.overViewLabel.text = self.overView
                self.releaseDateLabel.text = "Release Date: \(self.releaseDate!)"
                self.ratingLabel.text = "Rating: \(self.rating!) / 10"
                self.similarRequest()
                self.genreIDArrayConversion(insert: self.genreID!)
                self.genreLabel.text = "Similar Movies - \(self.genreNameArray.joined(separator: ","))"
                self.genreName = self.genreNameArray.joined(separator: ",")
            }
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

