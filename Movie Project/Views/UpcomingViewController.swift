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
    
    let searchController = UISearchController()
    
    var upcomingMovieTitleArray: [String] = []
    var upcomingMoviePosterArray: [String] = []
    
    var pageCount: Int = 1
    
    var isPaginating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Upcoming Movies"
        
        setupSearchController()
        
        upcomingCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        upcomingCollectionView.delegate = self
        upcomingCollectionView.dataSource = self
        
        view.addSubview(upcomingCollectionView)
        self.upcomingRequest()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        upcomingCollectionView.frame = view.bounds
    }
    
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func upcomingRequest(pagination: Bool = false) {
        
        if pagination {
            isPaginating = true
        }
        
        let upcomingURL = "\(Support.baseURL)\(Support.upcomingMovieEndPoint)?api_key=\(Support.apiKey)&page=\(pageCount)"
        
        Alamofire.request(upcomingURL, method: .get).responseJSON { response in
            
            switch response.result {
                
            case .success:
                
                let upcomingJSON: JSON = JSON(response.result.value!)
                
                let upcomingArrayCount = upcomingJSON["results"].array?.count ?? 0
                
                for u in 0..<upcomingArrayCount {
                    
                    let title = upcomingJSON["results"][u]["title"].stringValue
                    let posterImage = upcomingJSON["results"][u]["poster_path"].stringValue
                    
                    self.upcomingMovieTitleArray.append(title)
                    self.upcomingMoviePosterArray.append(posterImage)
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

//MARK: - UICollectionViewDelegate & DataSource Methods

extension UpcomingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingMovieTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
                as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.insertTitle(with: upcomingMovieTitleArray[indexPath.row])
        cell.insertImage(with: upcomingMoviePosterArray[indexPath.row])
        
        return cell
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
            //fetch more data
            self.pageCount += 1
            self.upcomingRequest(pagination: true)
        }
    }
}


