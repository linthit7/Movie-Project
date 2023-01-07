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
    
    let searchController = UISearchController()
     
    var popularMovieTitleArray: [String] = []
    var popularMoviePosterArray: [String] = []
    
    var pageCount: Int = 1
    
    var isPaginating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        
        setupSearchController()
        
        //        popularCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        popularCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        
        view.addSubview(popularCollectionView)
        self.popularRequest()
        
        popularCollectionView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        popularCollectionView.frame = view.bounds
    }
    
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func popularRequest(pagination: Bool = false) {
        
        //        let popularURL = "https://api.themoviedb.org/3/movie/popular?api_key=bc1f66a36bd7929eb408d7facc60ec74&page=1"
        
        if pagination {
            isPaginating = true
        }
        
        let popularURL = "\(Support.baseURL)\(Support.popularMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
        
        Alamofire.request(popularURL, method: .get).responseJSON { response in
            
            switch response.result {
                
            case .success:
                
                let popularJSON: JSON = JSON(response.result.value!)
                
                let popularArrayCount = popularJSON["results"].array?.count ?? 0
                //                print(popularArrayCount)
                
                for p in 0..<popularArrayCount {
                    
                    let title = popularJSON["results"][p]["title"].stringValue
                    let posterImage = popularJSON["results"][p]["poster_path"].stringValue
                    
                    self.popularMovieTitleArray.append(title)
                    self.popularMoviePosterArray.append(posterImage)
                    
                    self.popularCollectionView.reloadData()
                    //                    print(m)
                    //                    print(title)
                    //                    print(self.popularMovieTitleArray)
                    //                    print(posterImage)
                }
            case .failure(let error):
                print(error)
            }
            
            if pagination {
                self.isPaginating = false
            }
        }
        
    }
    
//    private func createSpinnerFooter() -> UIView {
//
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
//
//        let spinner = UIActivityIndicatorView()
//        spinner.center = footerView.center
//        footerView.addSubview(spinner)
//        spinner.startAnimating()
//
//        return footerView
//    }
    
}

//MARK: - CollectionViewDelegate & DataSource Methods

extension PopularViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //        collectionView.reloadData()
        return popularMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: popularMovieTitleArray[indexPath.row])
        cell.insertImage(with: popularMoviePosterArray[indexPath.row])
        //        collectionView.reloadData()
        return cell
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
            self.pageCount += 1
            self.popularRequest(pagination: true)
        }
    }
}



