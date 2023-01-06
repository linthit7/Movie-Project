//
//  PopularViewController.swift
//  Movie Project
//
//  Created by Lin Thit Khant on 1/5/23.
//

import UIKit

class PopularViewController: UIViewController {
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        
        setupSearchController()
        
        popularCollectionView.register(UINib(nibName: MovieCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        
        view.addSubview(popularCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        popularCollectionView.frame = view.bounds
    }
    
    func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: - Collection View Delegate & Data Source Methods

extension PopularViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = popularCollectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
        
        return cell
    }
}

//MARK: - Collection View DelegateFlowLayout Methods

extension PopularViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/3.5, height: collectionView.frame.size.height/4)
    }
}


