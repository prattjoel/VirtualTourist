//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Joel on 11/29/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var title: String?
    @NSManaged public var id: String?
    @NSManaged public var url: String
    @NSManaged public var dateTaken: Date?
    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin

}
