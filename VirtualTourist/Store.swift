//
//  Store.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Store {
    
    let stack = CoreDataStack(modelName: "Model")
    var photoStore = [Photo]()
    
    func getPhotos(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]?, context: NSManagedObjectContext?) throws -> [Photo]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        //        guard let predicateForFetch = predicate else {
        //            print("no predicate found for fethc request")
        //            return nil
        //        }
        
        fetchRequest.predicate = predicate
        
        // print("\n predicate for fetch request: \(fetchRequest.predicate) \n")
        // print("\n sort descriptors for fetch request: \(fetchRequest.sortDescriptors) \n")
        
        
        
        var mainQPhotos: [Photo]?
        var fetchError: Error?
        
        context?.performAndWait({
            do {
                mainQPhotos = try context?.fetch(fetchRequest) as! [Photo]?
            } catch let error {
                fetchError = error
                
            }
        })
        
        guard let photos = mainQPhotos else {
            throw fetchError!
        }
        
        //  print("\n photos from getPhotos Mehtod: \(photos) \n")
        
        return photos
        
        
    }
    
//    func addPhotoImage(photos: [Photo], context: NSManagedObjectContext, completionForImage: @escaping (Photo) -> Void, completion: @escaping () -> Void) -> Void {
//        
//        DispatchQueue.global(qos: .background).async {
//            for photo in photos {
//                if photo.image != nil {
//                    completionForImage(photo)
//                } else {
//                    
//                    
//                    //let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//                    //privateContext.parent = context
//                    
//                    //privateContext.perform {
//                    let urlString = photo.url
//                    let imageData = self.convertImageData(urlString: urlString)
//                    photo.imageData = imageData
//                    photo.image = UIImage(data: photo.imageData as! Data)
//                    
//                    completionForImage(photo)
//                    // }
//                    
//                }
//            }
//            
//            completion()
//        }
//        // return photos
//    }
    
    func addPhotoImage(photo: Photo, context: NSManagedObjectContext, completion: @escaping () -> Void) -> Void {
        
        DispatchQueue.global(qos: .background).async {
            
                if photo.image != nil {
                    completion()
                } else {
                    
                    
                    //let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    //privateContext.parent = context
                    
                    //privateContext.perform {
                    let urlString = photo.url
                    let imageData = self.convertImageData(urlString: urlString)
                    photo.imageData = imageData
                    photo.image = UIImage(data: photo.imageData as! Data)
                    
                    completion()

                    
                }
            
        }
        // return photos
    }
    
    // Convert url for image to NSData
    func convertImageData(urlString: String) -> NSData {
        var imageData = NSData()
        
        let url = NSURL(string: urlString)
        
        if let image = NSData(contentsOf: url! as URL) {
            imageData = image
        } else {
            print("Could not convert url to image data in Store \n")
            
        }
        
        return imageData
    }
}
