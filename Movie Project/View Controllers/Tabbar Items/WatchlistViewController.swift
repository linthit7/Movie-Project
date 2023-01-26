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
    
    var watchList: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.title = "Watch List"
            
            self.watchlistCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.watchlistCollectionView.delegate = self
            self.watchlistCollectionView.dataSource = self
            self.watchlistCollectionView.collectionViewLayout = self.configureLayout()
            self.movieFetch()
            self.watchlistCollectionView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        watchlistCollectionView.frame = view.bounds
    }
    
    private func movieFetch() {
        watchList = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return }
            self.watchList = result
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
//        let movieDetailVC = MovieDetailViewController()
//
//        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
//
//        dataPassingQueue.async {
//            movieDetailVC.watchListMovie = self.watchList[indexPath.row]
//            movieDetailVC.vc = "WatchlistViewController"
//        }
//        navigationController?.pushViewController(movieDetailVC, animated: true)
        
        let movieVC = MovieViewController()
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieVC.watchListMovie = self.watchList[indexPath.row]
            movieVC.vc = "WatchlistViewController"
        }
        navigationController?.pushViewController(movieVC, animated: true)
    }
    
}

//MARK: - UICollectionView Datasource and Delegate Methods

extension WatchlistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: watchList[indexPath.row].value(forKey: "movieTitle") as! String)
        cell.insertImage(with: watchList[indexPath.row].value(forKey: "posterImage") as! String)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout Methods

extension WatchlistViewController {
    
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


