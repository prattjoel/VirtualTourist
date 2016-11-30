//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let coreDataStack = CoreDataStack(modelName: "Model")
    var store = Store()
    var collectionDataSource = CollectionDataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = collectionDataSource
        
        let context = coreDataStack?.context
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: 40.837049, lon: -73.865430, context: context!) { success, result, error in
            
            if success {
                
                // if let photos = result {
                //  photoStore = photos
                do {
                    try self.coreDataStack?.saveContext()
                } catch let error {
                    print("error saving context \(error)")
                }
                
                let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
                let photoStore = try! self.store.getPhotos(sortDescriptors: sortDescriptor)
                
                OperationQueue.main.addOperation {
                    self.store.photoStore = photoStore
                    self.collectionDataSource.photos = photoStore
                    self.collectionView.reloadData()
                }
                
                
                print("\n photos from fetch request: \(photoStore) \n")
                print("\n photos in store: \(self.store.photoStore) \n")
                
            } else {
                print("error with request: \(error)")
            }
        }

        
    }
}
