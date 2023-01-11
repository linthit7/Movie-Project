//
//  FavoriteViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit
import CoreData

class WatchlistViewController: UIViewController {
    
    @IBOutlet weak var watchlistCollectionView: UICollectionView!
    
    var watchListMovieTitleArray: [String] = []
    var watchListMoviePosterArray: [String] = []
    
    var watchListMovieBackDropArray: [String] = []
    var watchListMovieOverViewArray: [String] = []
    var watchListMovieReleaseDateArray: [String] = []
    var watchListMovieRatingArray: [Float] = []
    var watchListMovieIDArray: [Int] = []
    var watchListMovieFavoriteStateArray: [Bool] = []
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .systemBackground
        title = "Watch List"
        
        watchlistCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        watchlistCollectionView.delegate = self
        watchlistCollectionView.dataSource = self
        movieFetch()
        watchlistCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        watchlistCollectionView.frame = view.bounds
    }
    
    private func movieFetch() {
        
        watchListMovieTitleArray = []
        watchListMoviePosterArray = []
        watchListMovieBackDropArray = []
        watchListMovieOverViewArray = []
        watchListMovieReleaseDateArray = []
        watchListMovieRatingArray = []
        watchListMovieIDArray = []
        watchListMovieFavoriteStateArray = []

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return }
            
            for data in result {
                watchListMovieFavoriteStateArray.append(data.value(forKey: "favoriteState") as! Bool)
                watchListMovieIDArray.append(data.value(forKey: "movieID") as! Int)
                watchListMovieRatingArray.append(data.value(forKey: "rating") as! Float)
                watchListMovieBackDropArray.append(data.value(forKey: "backDropImage") as! String)
                watchListMovieTitleArray.append(data.value(forKey: "movieTitle") as! String)
                watchListMovieOverViewArray.append(data.value(forKey: "overView") as! String)
                watchListMovieReleaseDateArray.append(data.value(forKey: "releaseDate") as! String)
                watchListMoviePosterArray.append(data.value(forKey: "posterImage") as! String)
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.movieTitle = self.watchListMovieTitleArray[indexPath.row]
            movieDetailVC.backDropImage = self.watchListMovieBackDropArray[indexPath.row]
            movieDetailVC.overView = self.watchListMovieOverViewArray[indexPath.row]
            movieDetailVC.releaseDate = self.watchListMovieReleaseDateArray[indexPath.row]
            movieDetailVC.rating = self.watchListMovieRatingArray[indexPath.row]
            movieDetailVC.movieID = self.watchListMovieIDArray[indexPath.row]
            movieDetailVC.posterImage = self.watchListMoviePosterArray[indexPath.row]
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
}

//MARK: - UICollectionView Datasource and Delegate Methods

extension WatchlistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchListMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: watchListMovieTitleArray[indexPath.row])
        cell.insertImage(with: watchListMoviePosterArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout Methods

extension WatchlistViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3.5, height: collectionView.frame.height/4)
    }
}


