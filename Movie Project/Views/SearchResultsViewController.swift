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
    var queryName: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear searchResultsViewController")
        
        DispatchQueue.main.async {
            self.setupSearchController()
            self.navigationController?.navigationBar.tintColor = .label
            self.searchResultsCollectionView.collectionViewLayout = self.configureLayout()
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
        let movieDetailVC = MovieDetailViewController()
        
        let dataPassingQueue = DispatchQueue(label: "dataPassingRequest", qos: .userInitiated)
        
        dataPassingQueue.async {
            movieDetailVC.movie = self.searchMovieList[indexPath.row]
            movieDetailVC.vc = "SearchResultsViewController"
        }
        navigationController?.pushViewController(movieDetailVC, animated: true)
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
        request.movieRequest(url: "SearchResultsVC", queryName: text) { movieResult, _, total in
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

extension SearchResultsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (searchResultsCollectionView.contentSize.height-100 - scrollView.frame.size.height) {
            
            request.movieRequest(url: "SearchResultsVC", queryName: queryName, pagination: true, pageCount: searchPageCount, pageTotal: searchPageTotal) { movieResult, count, _ in
                self.searchMovieList.append(contentsOf: movieResult)
                self.searchPageCount = count
                
                DispatchQueue.main.async {
                    self.searchResultsCollectionView.reloadData()
                }
            }
        }
    }
}

