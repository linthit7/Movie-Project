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
    
    var searchMovieTitleArray: [String] = []
    var searchMoviePosterArray: [String] = []
    var searchPageCount: Int = 1
    var searchPageTotal: Int = 0
    var isPaginating: Bool = false
    var queryName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetTempData()
        searchResultsCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
        view.addSubview(searchResultsCollectionView)
        setupSearchController()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.showsCancelButton = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchResultsCollectionView.frame = view.bounds
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
                    let searchArrayCount = searchJSON["results"].array?.count ?? 0
                    self.searchPageTotal = searchJSON["total_pages"].intValue
                    print(self.searchPageTotal)
                    
                    
                    for s in 0..<searchArrayCount {
                        
                        let title = searchJSON["results"][s]["title"].stringValue
                        let posterImage = searchJSON["results"][s]["poster_path"].stringValue
                        
                        print(title)
                        print(posterImage)
                        self.searchMovieTitleArray.append(title)
                        self.searchMoviePosterArray.append(posterImage)
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
        searchMovieTitleArray = []
        searchMoviePosterArray = []
        searchPageCount = 1
        searchPageTotal = 0
        isPaginating = false
        queryName = ""
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
        return searchMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchPageTotal > 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.insertTitle(with: searchMovieTitleArray[indexPath.row])
            cell.insertImage(with: searchMoviePosterArray[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
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
            }
            self.searchRequest(pagination: true)
        }
    }
}

