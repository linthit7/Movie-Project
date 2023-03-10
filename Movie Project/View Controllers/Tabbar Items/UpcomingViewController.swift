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
    var upcomingPageCount: Int = 1
    var upcomingPageTotal: Int = 0
    var upcomingMovieList: [MovieResult] = []
    var movieDetailList: [MovieResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.navigationItem.title = "Upcoming Movies"
            self.configureNavItem()
        }
        self.upcomingCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        self.upcomingCollectionView.delegate = self
        self.upcomingCollectionView.dataSource = self
        self.upcomingCollectionView.collectionViewLayout = CustomCollectionView.configureLayout()
        request.movieRequest(url: getVC.upcomingVC) { movieList, _, total in
            self.upcomingMovieList.append(contentsOf: movieList)
            self.upcomingPageTotal = total
            DispatchQueue.main.async {
                self.upcomingCollectionView.reloadData()
            }
        }
        
    }
    
    private func configureNavItem() {
        navigationController?.navigationBar.tintColor = .label
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchItemTapped(_:)))
        navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc
    func searchItemTapped(_ sender: UIBarButtonItem!) {
        navigationController?.pushViewController(SearchResultsViewController(), animated: true)
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {        
        request.movieRequest(url: getVC.similarVC, id:  upcomingMovieList[indexPath.row].id) { movieResult, _, _ in
            self.movieDetailList.append(contentsOf: movieResult)
            
            let movieVC = MovieViewController()
            let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
            
            dataPassingQueue.async {
                movieVC.movie = self.upcomingMovieList[indexPath.row]
                movieVC.movieDetailList = self.movieDetailList
                movieVC.vc = getVC.upcomingVC
            }
            self.navigationController?.pushViewController(movieVC, animated: true)
            
        }
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
        cell.populateWithMovieResult(movie: upcomingMovieList[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - UIScrollViewDelegate Methods

extension UpcomingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Calling request")
        if upcomingPageCount < upcomingPageTotal {
            request.movieRequest(url: getVC.upcomingVC, pagination: true, pageCount: upcomingPageCount, pageTotal: upcomingPageTotal) { movieResult, count, pageTotal in
                self.upcomingMovieList.append(contentsOf: movieResult)
                self.upcomingPageCount = count
                self.upcomingPageTotal = pageTotal
                print("Page count", count)
                
                DispatchQueue.main.async {
                    self.upcomingCollectionView.reloadData()
                }
            }
        }
    }
}


