//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit
import CoreData

class LocationViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var coreDataStack: CoreDataStack?
    var store = Store()
    var collectionDataSource = CollectionDataSource()
    var currentPin : Pin?
    var context: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = collectionDataSource
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: currentPin!.lat, lon: currentPin!.lon, context: context!, pin: currentPin!) { success, result, error in
            
            if success {
                
//                if let photos = result {
//                    self.currentPin?.photo = photos
//                }
                do {
                    try self.coreDataStack?.saveContext()
                } catch let error {
                    print("error saving context \(error)")
                }
                
                print("currentPin for predicate: /n \(self.currentPin)")
                let predicate = NSPredicate(format: "%K == %@", "pin", "\(self.currentPin!)")
                
                let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
                let photoStore = try! self.store.getPhotos(predicate: predicate, sortDescriptors: sortDescriptor)
                //let photoStore = currentPin!.photo as [Photo]
                
//                let photosForPin = self.mutableSetValue(forKey: "photo")
//                photosForPin.addObjects(from: photoStore)
                
                OperationQueue.main.addOperation {
                    self.store.photoStore = photoStore
                    self.collectionDataSource.photos = photoStore
                    self.collectionView.reloadData()
                }
                
                
                print("\n photos from fetch request: \(photoStore) \n")
                print("\n photos in store: \(self.store.photoStore) \n")
                print("\n the current pin is: \(self.currentPin) \n")
                
            } else {
                print("error with request: \(error)")
            }
        }

        
    }
}
