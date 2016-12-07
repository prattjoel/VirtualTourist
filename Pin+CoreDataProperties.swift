//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Joel on 11/29/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var photo: Set<NSManagedObject> 

}
