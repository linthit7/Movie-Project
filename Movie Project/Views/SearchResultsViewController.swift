//
//  SearchResultsViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/8/23.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchResultsViewController: UIViewController {
    
    var searchController = UISearchController()
    
    @IBOutlet weak var searchResultsCollectionView: UICollectionView!
    
    var searchMovie: OnlineMovie!
    var searchMovieList: [MovieResult] = []
    
    var searchPageCount: Int = 1
    var searchPageTotal: Int = 0
    var isPaginating: Bool = false
    var queryName: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSearchController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.showsCancelButton = false
        navigationController?.navigationBar.tintColor = .label
        searchResultsCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
        view.addSubview(searchResultsCollectionView)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchResultsCollectionView.frame = view.bounds
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.movie = self.searchMovieList[indexPath.row]
            movieDetailVC.vc = "SearchResultsViewController"
        } 
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }

    //MARK: - Network Request Methods
    
    func searchRequest(queryName: String = "", pagination: Bool = false) {
        let requestQueue = DispatchQueue(label: "searchRequest", qos: .userInitiated)
        if pagination {
            isPaginating = true
        }
        let searchURL = "\(Support.baseURL)\(Support.searchMovieEndPoint)?api_key=\(Support.apiKey)&page=\(searchPageCount)&query=\(queryName)"
        requestQueue.async {
            Alamofire.request(searchURL, method: .get).responseJSON { response in
                switch response.result {
                case .success:
                    
                    let searchJSON: JSON = JSON(response.result.value!)
                    self.searchMovie = OnlineMovie.loadJSON(json: searchJSON)
                    self.searchMovieList.append(contentsOf: self.searchMovie.results)
                    print("search movie list count",queryName,searchJSON,self.searchPageCount)
                    if self.searchPageTotal == 0 {
                        self.searchPageTotal = self.searchMovie.total_pages
                    }
                    DispatchQueue.main.async {
                        self.searchResultsCollectionView.reloadData()
                    }
                case.failure(let error):
                    print(error)
                }
                if pagination {
                    self.isPaginating = false
                }
            }
        }
    }
    private func resetTempData() {
        searchPageCount = 1
        searchPageTotal = 0
        isPaginating = false
        queryName = ""
        searchMovieList = []
        searchResultsCollectionView.reloadData()
    }
}

//MARK: - UISearchBar Delegate Methods

extension SearchResultsViewController: UISearchBarDelegate {
    
    private func setupSearchController() {
           navigationItem.searchController = searchController
           searchController.searchBar.delegate = self
           navigationItem.hidesSearchBarWhenScrolling = false
       }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.showsCancelButton = true
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resetTempData()
        guard let text = searchBar.text else {
            return
        }
        queryName = text
        self.searchRequest(queryName: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetTempData()
        self.navigationController?.popViewController(animated: true)
    }
}



//MARK: - UICollectionView Delegate & DataSource Methods

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchPageTotal > 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.insertTitle(with: searchMovieList[indexPath.row].title)
            cell.insertImage(with: searchMovieList[indexPath.row].poster_path)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieDetailPassingMethod(for: indexPath)
    }
}

//MARK: - Collection View DelegateFlowLayout Methods

extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/3.5, height: collectionView.frame.size.height/4)
    }
}

//MARK: - UIScrollViewDelegate Methods

extension SearchResultsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (searchResultsCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            //check if it is paging
            guard !isPaginating else {
                return
            }
            //fetch more data
            if searchPageCount < searchPageTotal {
                self.searchPageCount += 1
                self.searchRequest(queryName: self.queryName, pagination: true)
            }
            
        }
    }
}

