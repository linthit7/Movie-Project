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
    var popularMovieList: [MovieResult] = []
    var movieDetailList: [MovieResult] = []
    var popularMoviePageCount: Int = 1
    var popularMoviePageTotal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.navigationItem.title = "Popular Movies"
            self.configureNavItem()
            
        }
        self.popularCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        self.popularCollectionView.delegate = self
        self.popularCollectionView.dataSource = self
        self.popularCollectionView.collectionViewLayout = CustomCollectionView.configureLayout()
        self.view.addSubview(self.popularCollectionView)
        request.movieRequest(url: getVC.upcomingVC) { movieList, _, total in
            self.popularMovieList.append(contentsOf: movieList)
            self.popularMoviePageTotal = total
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popularCollectionView.frame = view.bounds
    }
    
    
    private func configureNavItem() {
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemTapped(_:)))
        navigationItem.rightBarButtonItem = searchItem
    }
    @objc
    private func searchItemTapped(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(SearchResultsViewController(), animated: true)
    }
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        
        request.movieRequest(url: getVC.similarVC, id:  popularMovieList[indexPath.row].id) { movieResult, _, _ in
            self.movieDetailList.append(contentsOf: movieResult)
            
            let movieVC = MovieViewController()
            let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
            
            dataPassingQueue.async {
                movieVC.movie = self.popularMovieList[indexPath.row]
                movieVC.movieDetailList = self.movieDetailList
                movieVC.vc = getVC.popularVC
            }
            self.navigationController?.pushViewController(movieVC, animated: true)
        }
        
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
        cell.populateWithMovieResult(movie: popularMovieList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UIScrollViewDelegate Methods

extension PopularViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.popularCollectionView.contentOffset.y >= (self.popularCollectionView.contentSize.height - self.popularCollectionView.bounds.size.height))
        {
            request.movieRequest(url: getVC.popularVC, pagination: true, pageCount: popularMoviePageCount, pageTotal: popularMoviePageTotal) { movieResult, count, _ in
                self.popularMovieList.append(contentsOf: movieResult)
                self.popularMoviePageCount = count

                DispatchQueue.main.async {
                    self.popularCollectionView.reloadData()
                }
            }
        }

    }
}





