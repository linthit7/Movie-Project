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
    
    var favorite: [Movie] = []
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.title = "Favorite Movies"
            
            self.favoriteCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.favoriteCollectionView.delegate = self
            self.favoriteCollectionView.dataSource = self
            self.favoriteCollectionView.collectionViewLayout = self.configureLayout()
            self.movieFetch()
            self.favoriteCollectionView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        favoriteCollectionView.frame = view.bounds
    }
    
    private func movieFetch() {
        favorite = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [Movie] else { return }
            self.favorite = result
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        
        let movieVC = MovieViewController()
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieVC.watchListMovie = self.favorite[indexPath.row]
            movieVC.vc = "WatchlistViewController"
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
        cell.insertTitle(with: favorite[indexPath.row].movieTitle!)
        cell.insertImage(with: favorite[indexPath.row].posterImage!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout Methods

extension FavoriteViewController {
    
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20.00, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}


