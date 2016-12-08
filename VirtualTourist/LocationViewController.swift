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
    @IBOutlet weak var refreshButton: UIButton!
    
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
        
        
        guard let photos = photosForPin() else {
            print("there were no photos for the pin")
            return
        }
        
        if photos.count > 0 {
            self.store.photoStore = photos
            self.collectionDataSource.photos = photos
            self.collectionView.reloadData()
            refreshButton.isEnabled = true
            //self.addImagesToStore(photos: self.collectionDataSource.photos)
            //self.collectionView.reloadData()
            
        } else {
            getCurrentPhotos(lat: currentPin!.lat, lon: currentPin!.lon, afterRefresh: false, contextForPhotos: context!, pin: currentPin!)
        }
        
        
    }
    
    @IBAction func refreshPhotos(sender: UIButton) {
        // collectionDataSource.photos.removeAll()
        clearPhotosFromPin()
        getCurrentPhotos(lat:currentPin!.lat, lon: currentPin!.lon, afterRefresh: true, contextForPhotos: context!, pin: currentPin!)
        
    }
    
    // Fetch photos for the current Pin
    func photosForPin() -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
        let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
        let photosInContext = try! self.store.getPhotos(predicate: predicate, sortDescriptors: sortDescriptor, context: self.context)
        
        // print("\n Number of photos in context: \(photosInContext!.count) \n")
        
        return photosInContext
    }
    
    // Empty photos for current pin in preparation for refresh
    func clearPhotosFromPin(){
        if let photos = photosForPin() {
            for photo in photos {
                context?.delete(photo)
            }
            saveContext()
            collectionDataSource.photos.removeAll()
        }
    }
    
    //Save the Managed Object Context
    func saveContext() {
        do {
            try self.coreDataStack?.saveContext()
            print("context saved")
        } catch let error {
            print("error saving context \(error)")
        }
    }
    
    // Download photos for the current location
    func getCurrentPhotos(lat: Double, lon: Double, afterRefresh: Bool, contextForPhotos: NSManagedObjectContext, pin: Pin) {
        print("\n getCurrentPhotos datasource count before request: \(self.collectionDataSource.photos.count)")
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: lat, lon: lon, context: contextForPhotos, pin: pin, afterRefresh: afterRefresh) { success, result, error in
            
            if success {
                
                do {
                    try self.coreDataStack?.saveContext()
                } catch let error {
                    print("error saving context \(error)")
                }
                
                let photoStore = self.photosForPin()
                
                
                OperationQueue.main.addOperation {
                    self.store.photoStore = photoStore!
                    self.collectionDataSource.photos = photoStore!
                    self.collectionView.reloadData()
                    self.addImagesToStore(photos: self.collectionDataSource.photos)
                    
                    //self.collectionView.reloadData()
                    
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
    
    // Add Images for each photo object to the collection view
    func addImagesToStore(photos: [Photo]) {
        for photo in photos {
            store.addPhotoImage(photo: photo) { result in
                OperationQueue.main.addOperation {
                    let index = self.collectionDataSource.photos.index(of: photo)
                    let indexPath = IndexPath.init(row: index!, section: 0)
                    self.collectionView.reloadItems(at: [indexPath])
                    self.saveContext()
                }
            }
        }
        
        print("images added to store")
    }
    
    //    // MARK: - Collection View Delegate Methods
    
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
