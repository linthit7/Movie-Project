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
    
    let searchResultsVC = SearchResultsViewController()

    var popularMovieTitleArray: [String] = []
    var popularMoviePosterArray: [String] = []
    var popularPageCount: Int = 1
    var popularPageTotal: Int = 0
    var isPaginating: Bool = false
    
    var popularMovieBackDropArray: [String] = []
//    var popularGenreArray
    var popularMovieOverViewArray: [String] = []
    var popularMovieReleaseDateArray: [String] = []
    var popularMovieRatingArray: [Float] = []
    var popularMovieIDArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
    
        popularCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        view.addSubview(popularCollectionView)
        configureNavItem()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        popularCollectionView.frame = view.bounds
    }
    
    private func configureNavItem() {
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
            movieDetailVC.movieTitle = self.popularMovieTitleArray[indexPath.row]
            movieDetailVC.backDropImage = self.popularMovieBackDropArray[indexPath.row]
            movieDetailVC.overView = self.popularMovieOverViewArray[indexPath.row]
            movieDetailVC.releaseDate = self.popularMovieReleaseDateArray[indexPath.row]
            movieDetailVC.rating = self.popularMovieRatingArray[indexPath.row]
            movieDetailVC.movieID = self.popularMovieIDArray[indexPath.row]
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    //MARK: - Network Request Methods
    
    private func popularRequest(pagination: Bool = false) {
        let requestQueue = DispatchQueue(label: "popularRequest", qos: .userInitiated)
        
        if pagination {
            isPaginating = true
        }
        let popularURL = "\(Support.baseURL)\(Support.popularMovieEndPoint)?api_key=\(Support.apiKey)&page=\(popularPageCount)"
        requestQueue.async {
            Alamofire.request(popularURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    
                    let popularJSON: JSON = JSON(response.result.value!)
                    let popularArrayCount = popularJSON["results"].array?.count ?? 0
                    self.popularPageTotal = popularJSON["total_pages"].intValue

                    for p in 0..<popularArrayCount {
                        
                        let title = popularJSON["results"][p]["title"].stringValue
                        let posterImage = popularJSON["results"][p]["poster_path"].stringValue
                        let backDropImage = popularJSON["results"][p]["backdrop_path"].stringValue
                        let overView = popularJSON["results"][p]["overview"].stringValue
                        let releaseDate = popularJSON["results"][p]["release_date"].stringValue
                        let rating = popularJSON["results"][p]["vote_average"].floatValue
                        let movieID = popularJSON["results"][p]["id"].intValue
                        
                        self.popularMovieTitleArray.append(title)
                        self.popularMoviePosterArray.append(posterImage)
                        self.popularMovieBackDropArray.append(backDropImage)
                        self.popularMovieOverViewArray.append(overView)
                        self.popularMovieReleaseDateArray.append(releaseDate)
                        self.popularMovieRatingArray.append(rating)
                        self.popularMovieIDArray.append(movieID)
                        
                        self.popularCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
                if pagination {
                    self.isPaginating = false
                }
            }
        }
    }
}

//MARK: - CollectionViewDelegate & DataSource Methods

extension PopularViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: popularMovieTitleArray[indexPath.row])
        cell.insertImage(with: popularMoviePosterArray[indexPath.row])
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
            //check if it is paging
            guard !isPaginating else {
                return
            }
            //fetch more data
            if popularPageCount < popularPageTotal {
                self.popularPageCount += 1
            }
            self.popularRequest(pagination: true)
        }
    }
}



