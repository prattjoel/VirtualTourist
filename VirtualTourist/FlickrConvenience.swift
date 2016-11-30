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
    func getPhotosRequest(lat: Float, lon: Float, context: NSManagedObjectContext, completionHandlerForGetPhotosRequest: @escaping (Bool, [Photo]?, NSError?) -> Void) {
        
        let paramaters: [String: String] = [
            ParamaterKeys.Method: ParamaterValues.PhotoSearchMethod,
            ParamaterKeys.ApiKey: ParamaterValues.ApiKey,
            ParamaterKeys.Latitude: "\(lat)",
            ParamaterKeys.Longitude: "\(lon)",
            ParamaterKeys.SafeSearch: ParamaterValues.SafeSearch,
            ParamaterKeys.Format: ParamaterValues.JsonFormat,
            ParamaterKeys.NoJsonCallBack: ParamaterValues.NoJsonCallBack,
            ParamaterKeys.Extras: "\(ParamaterValues.MediumURL),\(ParamaterValues.DateTaken)"
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
            
            
            let photos = self.photosFromArray(photosArray: photosArray, context: context)
            
            
            //print("\(photosDictionary)")
            
            completionHandlerForGetPhotosRequest(true, photos, nil)
            
        }
    }
    
    // Return an array of Photo objects Json array of dictionaries
    func photosFromArray(photosArray: [[String: AnyObject]], context: NSManagedObjectContext) -> [Photo] {
        
        var photos = [Photo]()
        for photoDict in photosArray {
            let photo = photoFromDictionary(photoDict: photoDict, context: context)
            photos.append(photo!)
        }
        
        return photos
    }
    
    // Convert Json photo dictionary to Photo object
    func photoFromDictionary (photoDict: [String: AnyObject], context: NSManagedObjectContext) -> Photo? {
        var photoToSave: Photo!
        
        guard let dateTaken = photoDict[ResponseKeys.Date] as! String?,
            let id = photoDict[ResponseKeys.ID] as! String?,
            let title = photoDict[ResponseKeys.Title] as! String?,
            let urlString = photoDict[ResponseKeys.Url] as! String? else {
                print("Could get photo properties from Json")
                return nil
        }
        
        var imageData = NSData()
        let url = NSURL(string: urlString)
        
        if let image = NSData(contentsOf: url! as URL) {
            imageData = image
        } else {
            print("Could not convert url to image data")
        }
        
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let formattedDate = formatter.date(from: "\(dateTaken)") {
            date = formattedDate
            print("\n formatted date is: \(formattedDate) \n")
        } else {
            print("\n Could not get date from String \n ")
        }
        
        context.performAndWait() {
            
            photoToSave = Photo(inContext: context, date: date, id: id, title: title, url: url!, imageData: imageData)
            print("Photo to save: \(photoToSave)")
            
        }
        
        return photoToSave
    }
}