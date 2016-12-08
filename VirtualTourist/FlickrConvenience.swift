//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Joel on 11/14/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
    
    
    
    // MARK: Request to get photos from FLickr
    func getPhotosRequest(lat: Double, lon: Double, context: NSManagedObjectContext, pin: Pin, afterRefresh: Bool, completionHandlerForGetPhotosRequest: @escaping (Bool, [Photo]?, NSError?) -> Void) {
        
        let pagenumber = arc4random_uniform(10) + 1
        
        let paramaters: [String: String] = [
            ParamaterKeys.Method: ParamaterValues.PhotoSearchMethod,
            ParamaterKeys.ApiKey: ParamaterValues.ApiKey,
            ParamaterKeys.Latitude: "\(lat)",
            ParamaterKeys.Longitude: "\(lon)",
            ParamaterKeys.SafeSearch: ParamaterValues.SafeSearch,
            ParamaterKeys.Format: ParamaterValues.JsonFormat,
            ParamaterKeys.NoJsonCallBack: ParamaterValues.NoJsonCallBack,
            ParamaterKeys.Extras: "\(ParamaterValues.MediumURL),\(ParamaterValues.DateTaken)",
            ParamaterKeys.PageNumber: "\(pagenumber)",
            ParamaterKeys.NumberPerPage: ParamaterValues.NumberOfPhotos
        ]
        
        taskForGetMethod(parameters: paramaters as [String : AnyObject]) { (result, error) in
            
            guard error == nil else {
                completionHandlerForGetPhotosRequest(false, nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "No result from getPhotosRequest"]))
                return
            }
            
            //print("Result from photos request: \n \(result)")
            
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse getPhotosRequest"]))
                return
            }
            
            guard let photosArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not get individual photos from photDictionary in getPhotosRequest"]))
                return
            }
            
            
            let photos = self.photosFromArray(photosArray: photosArray, context: context, pin: pin)
            
            
            //print("\(photosDictionary)")
            
            completionHandlerForGetPhotosRequest(true, photos, nil)
            
        }
    }
    
    // Return an array of Photo objects Json array of dictionaries
    func photosFromArray(photosArray: [[String: AnyObject]], context: NSManagedObjectContext, pin: Pin) -> [Photo] {
        
        var photos = [Photo]()
        for photoDict in photosArray {
            let photo = photoFromDictionary(photoDict: photoDict, context: context, pin: pin)
            photos.append(photo!)
        }
        
        return photos
    }
    
    // Convert Json photo dictionary to Photo object
    func photoFromDictionary (photoDict: [String: AnyObject], context: NSManagedObjectContext, pin: Pin) -> Photo? {
        var photoToSave: Photo!
        
        guard let dateTaken = photoDict[ResponseKeys.Date] as! String?,
            let id = photoDict[ResponseKeys.ID] as! String?,
            let title = photoDict[ResponseKeys.Title] as! String?,
            let urlString = photoDict[ResponseKeys.Url] as! String? else {
                print("Couldn't get photo properties from Json")
                return nil
        }
        
        if let photo = checkDuplicatePhoto(id: id, context: context) {
            photoToSave = photo
            // print("\n We have a duplicate photo! \n")
        } else {
            
//            guard let urlFromString = NSURL(string: urlString) else {
//                print("could not convert \(urlString) to NSURL")
//                return nil
//            }
            
           // let imageData = convertImageData(urlString: urlString)
            
            let date = formattedDate(dateToFormat: dateTaken)
            
            context.performAndWait() {
                // print("\n pin for photoToSave (before created): \(pin) \n")
                photoToSave = Photo(inContext: context, date: date, id: id, title: title, url: urlString, imageData: nil)
                photoToSave.pin = pin 
              // print("Photo to save: \(photoToSave)")
                
//                photoToSave.setValue(pin, forKey: "pin")
//               print("\n pin after photoToSave created: \(photoToSave.pin) \n")
                // let pinForPhoto = pin.mutableSetValue(forKey: "photo")
                // pinForPhoto.add(photoToSave)
                // print("\n pin lat from photoToSave: \(photoToSave.pin.lat), from pin: \(pin.lat) \n")
            }
        }
        
        return photoToSave
    }
    
    // Check for photos already saved
    func checkDuplicatePhoto(id: String, context: NSManagedObjectContext) -> Photo? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "id == \(id)")
        fr.predicate = predicate
        
        var photos: [Photo]!
        context.performAndWait {
            photos = try! context.fetch(fr) as! [Photo]
        }
        
        if photos.count > 0 {
            return photos.first
        } else {
            return nil
        }
        
    }
    
    // Convert url for image to NSData
    func convertImageData(urlString: String) -> NSData {
        var imageData = NSData()
        
        let url = NSURL(string: urlString)
        
        if let image = NSData(contentsOf: url! as URL) {
            imageData = image
        } else {
            print("Could not convert url to image data")

        }
        
        return imageData
    }
    
    // Format date to Date type
    func formattedDate(dateToFormat: String) -> Date {
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let formattedDate = formatter.date(from: "\(dateToFormat)") {
            date = formattedDate
            // print("\n formatted date is: \(formattedDate) \n")
            
        } else {
            print("\n Could not get date from String \n ")
        }
        return date
    }
}
