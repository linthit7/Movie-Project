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
                        
                        self.popularMovieTitleArray.append(title)
                        self.popularMoviePosterArray.append(posterImage)
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



