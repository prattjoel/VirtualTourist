//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LocationViewController: UIViewController, UICollectionViewDelegate, MKMapViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var coreDataStack: CoreDataStack?
    var store = Store()
    var collectionDataSource = CollectionDataSource()
    var currentPin : Pin?
    var objContext: NSManagedObjectContext?
    var cell = PhotoCell()
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshPhotos))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        createMapPin()
        
        collectionView.dataSource = collectionDataSource
        collectionView.delegate = self
        
        guard let photos = photosForPin() else {
            print("there were no photos for the pin")
            return
        }
        if photos.count > 0 {
            self.collectionDataSource.photos = photos
            self.collectionView.reloadData()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
        } else {
            if let pin = currentPin, let context = objContext {
                getCurrentPhotos(lat: pin.lat, lon: pin.lon, afterRefresh: false, contextForPhotos: context, pin: pin)
            } else {
                print("no current pin or context")
            }
        }
    }
    
    //MARK: Get photos for pin
    
    // Get photos for the current location
    func getCurrentPhotos(lat: Double, lon: Double, afterRefresh: Bool, contextForPhotos: NSManagedObjectContext, pin: Pin) {
        
        FlickrClient.sharedInstance().getPhotosForPageNumber(lat: lat, lon: lon, context: contextForPhotos, pin: pin, afterRefresh: afterRefresh) { success, result, error in
            
            if success {
                if result != nil {
                    DispatchQueue.main.async {
                        self.saveContext()
                        
                        let photoStore = self.photosForPin()
                        self.collectionDataSource.photos = photoStore!
                        self.collectionView.reloadData()
                        self.addImagesToStore(photos: self.collectionDataSource.photos)
                    }
                } else {
                    self.presentAlertContoller(title: "No photos found", message: "No photos found for this location.  Please select another location")
                    print("No photos found for this location")
                }
                
            } else {
                print("error with request: \(error)")
                self.presentAlertContoller(title: "Request Error", message: "Looks like something went wrong.  Try again in a few minutes.")
            }
        }
    }
    
    // Get new photos for pin
    func refreshPhotos() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        clearPhotosFromPin()
        
            if let pin = currentPin, let context = objContext {
            getCurrentPhotos(lat:pin.lat, lon: pin.lon, afterRefresh: true, contextForPhotos: context, pin: currentPin!)
        } else {
            print("no current pin or context")
        }
        
    }
    
    // Fetch photos for the current Pin
    func photosForPin() -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [self.currentPin!])
        let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
        let photosInContext = try! self.store.getPhotos(predicate: predicate, sortDescriptors: sortDescriptor, context: self.objContext)
        
        return photosInContext
    }
    
    // Add Images for each photo object to the collection view
    func addImagesToStore(photos: [Photo]) {
        var imageCount = 0
        guard let context = objContext else {
            print("No context for addImagesToStore")
            return
        }
        for photo in photos {
            self.store.addPhotoImage(photo: photo, context: context) { data in
                
                DispatchQueue.main.async {
                    photo.imageData = data
                    photo.image = UIImage(data: photo.imageData as! Data)
                    if let index = self.collectionDataSource.photos.index(of: photo) {
                        let indexPath = IndexPath.init(row: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                        imageCount += 1
                        if imageCount == photos.count {
                            self.saveContext()
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                        }
                    } else {
                        print("No index found for addImagesToStore")
                    }
                }
            }
        }
    }
    
    //MARK: Context helper methods
    
    //Save the Managed Object Context
    func saveContext() {
        
        do {
            try self.coreDataStack?.saveContext()
        } catch let error {
            print("error saving context \(error)")
        }
    }
    
    // Empty photos for current pin in preparation for refresh
    func clearPhotosFromPin(){
        if let photos = photosForPin() {
            for photo in photos {
                if let context = objContext {
                    context.delete(photo)
                } else {
                    print("No context found to delete photos in clearPhotosFromPin")
                }
            }
            saveContext()
            collectionDataSource.photos.removeAll()
        }
    }
    
    //MARK: Mapview helper method
    
    //Creat pin for mapView
    
    func createMapPin(){
        
        if let pin = currentPin{
            let coordinate = CLLocationCoordinate2DMake(pin.lat, pin.lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
            mapView.addAnnotation(annotation)
            
        }
    }
    
    // MARK: - MapView Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            
            
        } else {
            pinView!.annotation = annotation
        }
        
        
        return pinView
    }
    
    func presentAlertContoller(title: String, message: String) {
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { handler in
            self.objContext?.delete(self.currentPin!)
            self.saveContext()
            
            if let controller = self.navigationController {
                controller.popViewController(animated: true)
            } else {
                print("No nav controller found")
            }
        }
        
        alertContoller.addAction(okAction)
        
        present(alertContoller, animated: true, completion: nil)
    }
    
    // MARK: - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = collectionDataSource.photos[indexPath.row]
        objContext?.delete(photo)
        
        saveContext()
        
        self.collectionDataSource.photos.remove(at: indexPath.row)
        
        self.collectionView.deleteItems(at: [indexPath])
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = view.frame.size.width / 3.2
        return CGSize(width: width, height: width)
    }
    
    
}
