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
    var CoreStack = CoreDataStack(modelName: "Model")
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.removeAnnotations(annotations)
        fetchPinsFromContext()
    }
    
    // MARK: - Pin creation methods
    
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
            
            guard let stack = CoreStack else {
                print("No stack found for addPin")
                return
            }
            
            if let pin = addPinToContext(context: stack.context, coordinate: coordinate) {
                pins.append(pin)
                mapView.removeAnnotations(annotations)
                
                fetchPinsFromContext()
            } else {
                print("no pin found for addPin")
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
        
        context.performAndWait {
            pinsToCheck = try! context.fetch(fr) as! [Pin]
        }
        
        if pinsToCheck.count > 0 {
            return pinsToCheck.first
        } else {
            context.performAndWait {
                pin = Pin.init(lat: lat, lon: lon, incontext: context)
            }
            
            do {
                try context.save()
            } catch let error {
                print("error saving context in addPinToContext: \(error)")
            }
            return pin
        }
    }
    
    //MARK: - Adding pins to the Map
    
    // Get pins from context to populate map view.
    func fetchPinsFromContext() {
        guard let stack = CoreStack else {
            print("No stack found for fetchPinsFromContext")
            return
        }
        let context = stack.context
        var pins: [Pin]?
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        context.performAndWait {
            pins = try! context.fetch(fr) as! [Pin]
        }
        addPinsToMap(pins: pins!)
    }
    
    // Adds pins from context to map view
    func addPinsToMap(pins: [Pin]) {
        annotations.removeAll()
       self.pins.removeAll()
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
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.isSelected == true {
            
            if let index = annotations.index(of: view.annotation as! MKPointAnnotation) {
                
                let pin = pins[index]
                
                let controller = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
                controller.currentPin = pin
                guard let stack = CoreStack else {
                    print("No stack found for didSelect View")
                    return
                }
                controller.objContext = stack.context
                controller.coreDataStack = stack
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                print("No index found for selected pin in didSelect view")
            }
        }
    }
}
