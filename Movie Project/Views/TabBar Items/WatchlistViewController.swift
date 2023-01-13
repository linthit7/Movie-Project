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
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.watchListMovie = self.watchList[indexPath.row]
            movieDetailVC.vc = "WatchlistViewController"
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
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

extension WatchlistViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3.5, height: collectionView.frame.height/4)
    }
}


