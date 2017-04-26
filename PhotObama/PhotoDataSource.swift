//
//  PhotoDataSource.swift
//  PhotObama
//
//  Created by Lindsay Pond on 4/10/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    enum Constants {
        static let cellReuseID = "PhotoCollectionViewCell"
    }
    var photos = [Photo]()
    
    
    // MARK: UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseID, for: indexPath)
        
        
        return cell
    }
    
}
