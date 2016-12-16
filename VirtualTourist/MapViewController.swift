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
    // static var coreDataStack = CoreDataStack(modelName: "Model")
    var stack = CoreDataStack(modelName: "Model")
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // stack = MapViewController.coreDataStack
        
        mapView.removeAnnotations(annotations)
        
        fetchPinsFromContext()
        print("\n the annotations count in viewWillAppear is: \(annotations.count) \n")
    }
    
    
    //MARK: - Initial pin creation methods
    
    // Create pin after long press
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        longPressRecognizer.minimumPressDuration = 1.0
        
        if longPressRecognizer.state == UIGestureRecognizerState.began {
            let location = longPressRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
            
            if let pin = addPinToContext(context: stack!.context, coordinate: coordinate) {
                pins.append(pin)
                
                let controller = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
                controller.currentPin = pin
               // print("\n pin set in map controllert: \(controller.currentPin) \n")
                controller.context = stack!.context
                controller.coreDataStack = stack
                self.navigationController?.pushViewController(controller, animated: true)
                //present(controller, animated: true, completion: nil)
                // print("\n coordinate if location is: \(annotation.coordinate) \n")
            }
        }
        
        
    }
    
    // Add pin to context
    func addPinToContext (context: NSManagedObjectContext, coordinate: CLLocationCoordinate2D) -> Pin? {
        var pinsToCheck: [Pin]!
        var pin: Pin?
        
        let lat = Double(coordinate.latitude)
        let lon = Double(coordinate.longitude)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "lat == %@ AND lon == %@", "\(lat)", "\(lon)" )
        fr.predicate = predicate
        
       // print("\n ------ predicate for pinsToCheck --------- \n \(fr.predicate)")
        
        context.performAndWait {
            pinsToCheck = try! context.fetch(fr) as! [Pin]
        }
        
        // print("\n pins to check returned: \(pinsToCheck) \n")
        
        if pinsToCheck.count > 0 {
            return pinsToCheck.first
        } else {
            context.performAndWait {
                pin = Pin.init(lat: lat, lon: lon, incontext: context)
            }
           // print("\n pin added to context: \(pin) \n")
            
           // pins.append(pin!)
            print("\n number of current pins is \(pins.count) \n")
            
            return pin
        }
    }
    
    //MARK: - Adding pins to the Map
    
    // Get pins from context to populate map view.
    func fetchPinsFromContext() {
        let contextForFetch = stack?.context
        var pins: [Pin]?
        
        if let context = contextForFetch {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            context.performAndWait {
                pins = try! context.fetch(fr) as! [Pin]
            }
            print("pins in context for fetch in MapView: \(pins?.count)")
        }
        addPinsToMap(pins: pins!)
    }
    
    // Adds pins from context to map view
    func addPinsToMap(pins: [Pin]) {
        annotations.removeAll()
        for pin in pins {
            
            let annotation = MKPointAnnotation()
            let lat = CLLocationDegrees(pin.lat)
            let lon = CLLocationDegrees(pin.lon)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.coordinate = coordinate
            annotations.append(annotation)
            self.pins.append(pin)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    // MARK:- MapView delegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = false
            
            
            
        } else {
            pinView!.annotation = annotation
        }
        
        //        if pinView?.isSelected == true {
        //            let coordinate = pinView?.annotation?.coordinate
        //
        //            let pin = addPinToContext(context: stack!.context, coordinate: coordinate!)
        //
        //            let controller = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        //            controller.currentPin = pin
        //            print("\n pin set in map controllert: \(controller.currentPin) \n")
        //            controller.context = stack!.context
        //            controller.coreDataStack = stack
        //            self.navigationController?.pushViewController(controller, animated: true)
        //        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // view.setSelected(false, animated: true)
        if view.isSelected == true {
            
            print("\n number of pins: \(pins.count)")
            print("\n number of annotations: \(annotations.count) \n")
            
            let index = annotations.index(of: view.annotation as! MKPointAnnotation)
            
            //let coordinate = view.annotation?.coordinate
            
            let pin = pins[index!]
            //print("\n the view's latitude is: \(view.annotation?.coordinate.latitude) \n")
            //print("\n the pin's latitude is: \(pin.lat) \n")
            
            let controller = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
            controller.currentPin = pin
            //print("\n pin set in map controllert: \(controller.currentPin) \n")
            controller.context = stack!.context
             controller.coreDataStack = stack
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        
    }
    
}
