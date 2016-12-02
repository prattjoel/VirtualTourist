//
//  CollectionDataSource.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit

class CollectionDataSource: NSObject, UICollectionViewDataSource {
    
    var photos = [Photo]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = "UICollectionViewCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        
        let imageData =  photo.imageData
        let image = UIImage(data: imageData as! Data)
        
        cell.cellImageView?.image = image
        
        return cell
    }
    
}
