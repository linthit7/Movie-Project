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
    
    let request = Request()
    var searchPageCount: Int = 1
    var searchPageTotal: Int = 0
    var searchMovieList: [MovieResult] = []
    var movieDetailList: [MovieResult] = []
    var queryName: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.setupSearchController()
            self.navigationController?.navigationBar.tintColor = .label
            self.searchResultsCollectionView.collectionViewLayout = CustomCollectionView.configureLayout()
            self.searchResultsCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            self.searchResultsCollectionView.delegate = self
            self.searchResultsCollectionView.dataSource = self
            self.view.addSubview(self.searchResultsCollectionView)
            Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.showKeyboard), userInfo: nil, repeats: false)
        }
    }
    
    @objc func showKeyboard() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }
    
    private func movieDetailPassingMethod(for indexPath: IndexPath) {
        request.movieRequest(url: getVC.similarVC, id:  searchMovieList[indexPath.row].id) { movieResult, _, _ in
            self.movieDetailList.append(contentsOf: movieResult)
            
            let movieVC = MovieViewController()
            let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
            
            dataPassingQueue.async {
                movieVC.movie = self.searchMovieList[indexPath.row]
                movieVC.movieDetailList = self.movieDetailList
                movieVC.vc = getVC.searchResultsVC
            }
            self.navigationController?.pushViewController(movieVC, animated: true)
        }
    }
    
    private func resetTempData() {
        searchPageCount = 1
        searchPageTotal = 0
        queryName = ""
        searchMovieList = []
        DispatchQueue.main.async {
            self.searchResultsCollectionView.reloadData()
        }
        
    }
}

//MARK: - UISearchBar Delegate Methods

extension SearchResultsViewController: UISearchBarDelegate, UITextFieldDelegate, UISearchControllerDelegate {
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.hidesBackButton = true
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
        request.movieRequest(url: getVC.searchResultsVC, queryName: text) { movieResult, _, total in
            self.searchMovieList = movieResult
            self.searchPageTotal = total
            
            DispatchQueue.main.async {
                self.searchResultsCollectionView.reloadData()
            }
        }
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
            cell.populateWithMovieResult(movie: searchMovieList[indexPath.row])
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

//MARK: - UIScrollViewDelegate Methods

extension SearchResultsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (searchResultsCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            
            request.movieRequest(url: getVC.searchResultsVC, queryName: queryName, pagination: true, pageCount: searchPageCount, pageTotal: searchPageTotal) { movieResult, count, _ in
                self.searchMovieList.append(contentsOf: movieResult)
                self.searchPageCount = count
                
                DispatchQueue.main.async {
                    self.searchResultsCollectionView.reloadData()
                }
            }
        }
    }
}

