//
//  FavoriteViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    @IBOutlet weak var pleaseLoginLabel: UILabel!
    var favorite: [Movie] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFavoriteView()
    }
    
    private func setupFavoriteView() {
        if AppDelegate.sessionState {
            DispatchQueue.main.async {
                self.navigationItem.title = "Favorite Movies"
                
            }
            self.favoriteCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.favoriteCollectionView.delegate = self
            self.favoriteCollectionView.dataSource = self
            self.favoriteCollectionView.collectionViewLayout = CustomCollectionView.configureLayout()
            self.favorite = MovieLogic.movieFetch()!
            self.favoriteCollectionView.reloadData()
            print("Online favorite")
        } else {
            DispatchQueue.main.async {
                self.favoriteCollectionView.alpha = 0
            }
            print("Offline favorite")
        }
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        
        let movieVC = MovieViewController()
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        dataPassingQueue.async {
            movieVC.watchListMovie = self.favorite[indexPath.row]
            movieVC.vc = getVC.favoriteVC
        }
        navigationController?.pushViewController(movieVC, animated: true)
    }
    
}

//MARK: - UICollectionView Datasource and Delegate Methods

extension FavoriteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorite.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.populateWithMovie(movie: favorite[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}


