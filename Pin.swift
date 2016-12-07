//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Joel on 11/29/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
class Pin: NSManagedObject {
    

    convenience init(lat: Double, lon: Double, incontext context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.lon = lon
        } else {
            fatalError("Unable to find entity")
        }
    }
    

}
