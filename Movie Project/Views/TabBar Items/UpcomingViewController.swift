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
    
    let searchResultsVC = SearchResultsViewController()
    
    
    var upcomingPageCount: Int = 1
    var upcomingPageTotal: Int = 0
    var isPaginating: Bool = false
    
    var upcomingMovie: OnlineMovie!
    var upcomingMovieList: [MovieResult] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .systemBackground
        title = "Upcoming Movies"
        
        upcomingCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
        view.addSubview(upcomingCollectionView)
        configureNavItem()
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
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.movie = self.upcomingMovieList[indexPath.row]
            movieDetailVC.vc = "UpcomingViewController"
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
    
    //MARK: - NetworkRequest Methods
    
    private func upcomingRequest(pagination: Bool = false) {
        let requestQueue = DispatchQueue(label: "popularRequest", qos: .userInitiated)
        if pagination {
            isPaginating = true
        }
        let upcomingURL = "\(Support.baseURL)\(Support.upcomingMovieEndPoint)?api_key=\(Support.apiKey)&page=\(upcomingPageCount)"
        
        requestQueue.async {
            Alamofire.request(upcomingURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    let upcomingJSON: JSON = JSON(response.result.value!)
                    self.upcomingMovie = OnlineMovie.loadJSON(json: upcomingJSON)
                    self.upcomingMovieList.append(contentsOf: self.upcomingMovie.results)
                    
                    if self.upcomingPageTotal == 0 {
                        self.upcomingPageTotal = self.upcomingMovie.total_pages
                    }
                    DispatchQueue.main.async {
                        self.upcomingCollectionView.reloadData()
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

extension UpcomingViewController:  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/3.5, height: collectionView.frame.height/4)
    }
}

//MARK: - UIScrollViewDelegate Methods

extension UpcomingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (upcomingCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            //check if it is paging
            guard !isPaginating else {
                return
            }
            if upcomingPageCount < upcomingPageTotal {
                //fetch more data
                self.upcomingPageCount += 1
            }
            self.upcomingRequest(pagination: true)
        }
    }
}


