//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Joel on 11/29/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {
    
    
    convenience init(inContext context: NSManagedObjectContext, date: Date, id: String, title: String, url: NSURL, imageData: NSData) {
        print("\n Photo object init called \n")
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.dateTaken = date
            self.id = id
            self.title = title
            self.url = url
            self.imageData = imageData
            // print("\n pin in photo managed object: \(self.pin) \n")
        } else {
            fatalError("Unable to find Entity")
        }
    }
}
