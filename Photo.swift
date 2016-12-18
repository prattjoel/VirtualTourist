//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Joel on 11/29/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
class Photo: NSManagedObject {
    
    var image: UIImage?
    
    convenience init(inContext context: NSManagedObjectContext, date: Date, id: String, title: String, url: String) {

        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.dateTaken = date
            self.id = id
            self.title = title
            self.url = url
            //self.imageData = imageData
        } else {
            fatalError("Unable to find Entity")
        }
    }
}
