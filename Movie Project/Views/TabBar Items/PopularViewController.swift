//
//  PopularViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class PopularViewController: UIViewController {
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    let request = Request()
    let searchResultsVC = SearchResultsViewController()
    var popularMovieList: [MovieResult] = []
    var popularMoviePageCount: Int = 1
    var popularMoviePageTotal: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Popular Movies"
        
        self.request.movieRequest(url: "PopularVC") { movieList, _, total in
            self.popularMovieList.append(contentsOf: movieList)
            self.popularMoviePageTotal = total
            
            DispatchQueue.main.async {
                self.popularCollectionView.reloadData()
            }
        }
        
        DispatchQueue.main.async {
            self.configureNavItem()
            self.popularCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.popularCollectionView.dataSource = self
            self.popularCollectionView.delegate = self
            self.view.addSubview(self.popularCollectionView)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        popularCollectionView.frame = view.bounds
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
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.movie = self.popularMovieList[indexPath.row]
            movieDetailVC.vc = "PopularViewController"
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

//MARK: - CollectionViewDelegate & DataSource Methods

extension PopularViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with:  (popularMovieList[indexPath.row].title))
        cell.insertImage(with: (popularMovieList[indexPath.row].poster_path))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - Collection View DelegateFlowLayout Methods

extension PopularViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/3.5, height: collectionView.frame.size.height/4)
    }
}

//MARK: - UIScrollViewDelegate Methods

extension PopularViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (popularCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            
            request.movieRequest(url: "PopularVC", pagination: true, pageCount: popularMoviePageCount, pageTotal: popularMoviePageTotal) { movieResult, count, _ in
                self.popularMovieList.append(contentsOf: movieResult)
                self.popularMoviePageCount = count
                
                DispatchQueue.main.async {
                    self.popularCollectionView.reloadData()
                }
            }
        }
    }
}





