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
        
        fetchRequest.predicate = predicate
        
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
        
        return photos
        
        
    }
    
    func addPhotoImage(photo: Photo, context: NSManagedObjectContext, completion: @escaping (NSData) -> Void) -> Void {
        let urlString = photo.url
        
        DispatchQueue.global(qos: .background).async {
            
            if photo.image != nil {
                completion(photo.imageData!)
            } else {
                
                let imageData = self.convertImageData(urlString: urlString)
                completion(imageData)
            }
        }
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
