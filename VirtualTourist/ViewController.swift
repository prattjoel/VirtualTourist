//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joel on 11/10/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func photoRequestButton(_ sender: UIButton) {
        
        FlickrClient.sharedInstance().getPhotosRequest(lat: 40.837049, lon: 74.417097) { success, result, error in
            
            if success {
                print("Results for photo dictionary: \n \(result)")
            } else {
                print("error: \(error)")
            }
        }
        
    }

}

