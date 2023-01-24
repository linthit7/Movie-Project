//
//  LastestViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpcomingViewController: UIViewController {
    
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    
    let request = Request()
    let searchResultsVC = SearchResultsViewController()
    var upcomingPageCount: Int = 1
    var upcomingPageTotal: Int = 0
    var upcomingMovieList: [MovieResult] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Upcoming Movies"
        
        
        request.movieRequest(url: "UpcomingVC") { movieList, _, total in
            self.upcomingMovieList.append(contentsOf: movieList)
            self.upcomingPageTotal = total
        }
        DispatchQueue.main.async {
            self.configureNavItem()
            self.upcomingCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.upcomingCollectionView.delegate = self
            self.upcomingCollectionView.dataSource = self
            self.upcomingCollectionView.collectionViewLayout = self.configureLayout()
            self.view.addSubview(self.upcomingCollectionView)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        upcomingCollectionView.frame = view.bounds
    }
    
    private func configureNavItem() {
        navigationController?.navigationBar.tintColor = .label
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemTapped(_:)))
        navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func searchItemTapped(_ sender: UIBarButtonItem!) {
        
        navigationController?.pushViewController(searchResultsVC, animated: true)
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
//        let movieDetailVC = MovieDetailViewController()
//
//        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
//
//        dataPassingQueue.async {
//            movieDetailVC.movie = self.upcomingMovieList[indexPath.row]
//            movieDetailVC.vc = "UpcomingViewController"
//        }
//        navigationController?.pushViewController(movieDetailVC, animated: true)
        
        let movieInfoVC = MovieInfoViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieInfoVC.movie = self.upcomingMovieList[indexPath.row]
            movieInfoVC.vc = "UpcomingViewController"
        }
        
        navigationController?.pushViewController(movieInfoVC, animated: true)
    }
}

//MARK: - UICollectionViewDelegate & DataSource Methods

extension UpcomingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
                as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: upcomingMovieList[indexPath.row].title)
        cell.insertImage(with: upcomingMovieList[indexPath.row].poster_path)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout Methods

extension UpcomingViewController {
    
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

//MARK: - UIScrollViewDelegate Methods

extension UpcomingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (upcomingCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            
            request.movieRequest(url: "UpcomingVC", pagination: true, pageCount: upcomingPageCount, pageTotal: upcomingPageTotal) { movieList, count, _ in
                self.upcomingMovieList.append(contentsOf: movieList)
                self.upcomingPageCount = count
            
                DispatchQueue.main.async {
                    self.upcomingCollectionView.reloadData()
                }
            }
            
            
        }
    }
}


