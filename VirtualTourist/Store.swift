//
//  Store.swift
//  VirtualTourist
//
//  Created by Joel on 11/30/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData

class Store {
    
    let stack = CoreDataStack(modelName: "Model")
    var photoStore = [Photo]()
    
    func getPhotos(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]?) throws -> [Photo] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQContext = stack?.context
        var mainQPhotos: [Photo]?
        var fetchError: Error?
        
        mainQContext?.performAndWait({
            do {
                mainQPhotos = try mainQContext?.fetch(fetchRequest) as! [Photo]?
            } catch let error {
                fetchError = error
                
            }
        })
        
        guard let photos = mainQPhotos else {
            throw fetchError!
        }
        
        return photos
        
        
    }
}
