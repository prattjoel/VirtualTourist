//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joel on 11/10/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let coreDataStack = CoreDataStack(modelName: "Model")
    var store = Store()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func photoRequestButton(_ sender: UIButton) {
        
        let context = coreDataStack?.context
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: 40.837049, lon: -73.865430, context: context!) { success, result, error in
            
            if success {
                
                // if let photos = result {
                      //  photoStore = photos
                    do {
                     try self.coreDataStack?.saveContext()
                    } catch let error {
                        print("error saving context \(error)")
                    }
                    
                    let sortDescriptor = [NSSortDescriptor(key: "dateTaken", ascending: true)]
                    let photoStore = try! self.store.getPhotos(sortDescriptors: sortDescriptor)
                    self.store.photoStore = photoStore
                
                print("\n photos from fetch request: \(photoStore) \n")
                print("\n photos in store: \(self.store.photoStore) \n")

            } else {
                print("error with request: \(error)")
            }
        }
        
    }

}

