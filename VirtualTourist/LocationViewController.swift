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
    var cell = PhotoCell()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = self
        
        print("\n viewDidLoad datasource count: \(collectionDataSource.photos.count)")
        
        // cell.indicator.startAnimating()
        
        
        
        guard let photos = photosForPin() else {
            return
        }
        
        if photos.count > 0 {
            self.store.photoStore = photos
            self.collectionDataSource.photos = photos
            self.collectionView.reloadData()
        } else {
            getCurrentPhotos(lat: currentPin!.lat, lon: currentPin!.lon, contextForPhotos: context!, pin: currentPin!)
            //            FlickrClient.sharedInstance().getPhotosRequest(lat: currentPin!.lat, lon: currentPin!.lon, context: context!, pin: currentPin!) { success, result, error in
            //
            //                if success {
            //
            //                    //                if let photos = result {
            //                    //                    self.currentPin?.photo = photos
            //                    //                }
            //                    do {
            //                        try self.coreDataStack?.saveContext()
            //                    } catch let error {
            //                        print("error saving context \(error)")
            //                    }
            //
            //                    // print("currentPin for predicate: \n \(self.currentPin)")
            //                    // let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
            //                    //let predicate = NSPredicate(format: "pin == %K", self.currentPin!)
            //
            //                    // let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
            //                    let photoStore = self.photosForPin()
            //                    // print("\n photo store after fetch: \(photoStore) \n")
            //                    //let photoStore = currentPin!.photo as [Photo]
            //
            //                    //                let photosForPin = self.mutableSetValue(forKey: "photo")
            //                    //                photosForPin.addObjects(from: photoStore)
            //
            //                    OperationQueue.main.addOperation {
            //                        self.store.photoStore = photoStore!
            //                        self.collectionDataSource.photos = photoStore!
            //                        self.collectionView.reloadData()
            //                    }
            //
            //
            //                    // print("\n photos from fetch request: \(photoStore) \n")
            //                    // print("\n photos in store: \(self.store.photoStore) \n")
            //                    // print("\n the current pin is: \(self.currentPin) \n")
            //
            //                } else {
            //                    print("error with request: \(error)")
            //                }
            //            }
        }
        
        
    }
    
    @IBAction func refreshPhotos(sender: UIButton) {
        getCurrentPhotos(lat:currentPin!.lat, lon: currentPin!.lon, contextForPhotos: context!, pin: currentPin!)
        
    }
    
    // Fetch photos for the current Pin
    func photosForPin() -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
        let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
        let photosInContext = try! self.store.getPhotos(predicate: predicate, sortDescriptors: sortDescriptor, context: self.context)
        
        return photosInContext
    }
    
    // Download photos for the current location
    func getCurrentPhotos(lat: Double, lon: Double, contextForPhotos: NSManagedObjectContext, pin: Pin) {
        print("\n getCurrentPhotos datasource count before request: \(self.collectionDataSource.photos.count)")
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: lat, lon: lon, context: contextForPhotos, pin: pin) { success, result, error in
            
            if success {
                
                //                if let photos = result {
                //                    self.currentPin?.photo = photos
                //                }
                //                OperationQueue.main.addOperation {
                //                    self.collectionDataSource.photos = result!
                //                    self.collectionView.reloadData()
                //
                //                    print("\n getCurrentPhotos datasource count: \(self.collectionDataSource.photos.count)")
                //                }
                
                do {
                    try self.coreDataStack?.saveContext()
                } catch let error {
                    print("error saving context \(error)")
                }
                
                // print("currentPin for predicate: \n \(self.currentPin)")
                // let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
                //let predicate = NSPredicate(format: "pin == %K", self.currentPin!)
                
                // let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
                let photoStore = self.photosForPin()
                // print("\n photo store after fetch: \(photoStore) \n")
                //let photoStore = currentPin!.photo as [Photo]
                
                //                let photosForPin = self.mutableSetValue(forKey: "photo")
                //                photosForPin.addObjects(from: photoStore)
                
                OperationQueue.main.addOperation {
                    self.store.photoStore = photoStore!
                    self.collectionDataSource.photos = photoStore!
                    self.collectionView.reloadData()
                    
                    print("\n getCurrentPhotos datasource count: \(self.collectionDataSource.photos.count)")
                }
                
                
                // print("\n photos from fetch request: \(photoStore) \n")
                // print("\n photos in store: \(self.store.photoStore) \n")
                // print("\n the current pin is: \(self.currentPin) \n")
                
            } else {
                print("error with request: \(error)")
            }
        }
        
    }
    
    //    // MARK: - Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = collectionDataSource.photos[indexPath.row]
        
        store.addPhotoImage(photo: photo) { result in
            
            // let photo = result[indexPath.row]
            // let image = UIImage(data: photo.imageData as! Data)
            OperationQueue.main.addOperation {
                let index = self.collectionDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(row: index, section: 0)
                
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotoCell {
                    
                    cell.cellImageView.image = photo.image
                }
            }
        }
    }
    
    
    
    //        let storeWithImages = store.addPhotoImage(photos: collectionDataSource.photos)
    //
    //        let photo = storeWithImages[indexPath.row]
    //        let image = UIImage(data: photo.imageData as! Data)
    //        OperationQueue.main.addOperation {
    //            let index = storeWithImages.index(of: photo)!
    //            let photoIndexPath = IndexPath(row: index, section: 0)
    //
    //            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotoCell {
    //
    //                cell.cellImageView.image = image
    //            }
    //        }
    //
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // print("\n photo count before deleted: \(collectionDataSource.photos.count) \n")
        // self.collectionView.remove
        // store.photoStore.remove(at: indexPath.row)
        let photo = collectionDataSource.photos[indexPath.row]
        context?.delete(photo)
        do {
            try coreDataStack?.saveContext()
        } catch let error {
            print("error saving context \(error)")
        }
        
        // let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
        // let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
        // let photosInContext = photosForPin()
        
        // print("\n Number of photos in context after deleted: \(photosInContext!.count) \n")
        
        
        
        // MapViewController.coreDataStack = coreDataStack
        self.collectionDataSource.photos.remove(at: indexPath.row)
        //  print("\n photo count after deleted: \(collectionDataSource.photos.count) \n")
        
        self.collectionView.deleteItems(at: [indexPath])
        // let photo = store.photoStore[indexPath.row]
        
        
        collectionView.reloadData()
    }
    
    
}
