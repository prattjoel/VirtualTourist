//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Joel on 12/1/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import MapKit
import UIKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var longPressRecognizer: UILongPressGestureRecognizer!
    
    var annotations = [MKPointAnnotation]()
    var pins = [Pin]()
    var stack = CoreDataStack(modelName: "Model")
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        longPressRecognizer.minimumPressDuration = 1.0
        
        if longPressRecognizer.state == UIGestureRecognizerState.began {
            let location = longPressRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
            
            let pin = addPinToContext(context: stack!.context, coordinate: coordinate)
            
            let controller = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
            controller.currentPin = pin
            print("\n pin set in map controllert: \(controller.currentPin) \n")
            controller.context = stack!.context
            controller.coreDataStack = stack
            present(controller, animated: true, completion: nil)
            // print("\n coordinate if location is: \(annotation.coordinate) \n")
        }
        
        
    }
    
    func addPinToContext (context: NSManagedObjectContext, coordinate: CLLocationCoordinate2D) -> Pin? {
        var pinsToCheck: [Pin]!
        var pin: Pin?
        
        let lat = Float(coordinate.latitude)
        let lon = Float(coordinate.longitude)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "lat == \(lat) AND lon == \(lon)")
        fr.predicate = predicate
        
        context.performAndWait {
            pinsToCheck = try! context.fetch(fr) as! [Pin]
        }
        
        if pinsToCheck.count > 0 {
            return pinsToCheck.first
        } else {
            context.performAndWait {
                pin = Pin.init(lat: lat, lon: lon, incontext: context)
            }
            print("\n pin added to context: \(pin) \n")
            
            pins.append(pin!)
            print("\n number of current pins is \(pins.count) \n")
            
            return pin
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
