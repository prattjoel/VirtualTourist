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
    
    
    //MARK: - Request for photos with random page number
    
    //Make request for photos based on pages available
    func getPhotosForPageNumber(lat: Double, lon: Double, context: NSManagedObjectContext, pin: Pin, afterRefresh: Bool, completionHandlerForGetPhotosForPageNumber: @escaping (Bool, [Photo]?, NSError?) -> Void) -> Void {
        getNumberOfPhotos(lat: lat, lon: lon, context: context, pin: pin, afterRefresh: afterRefresh){ (success, pages, error) in

            if success {
                guard let pagesForPhotos = pages else {
                    print("no pages found")
                    return
                }
                if pagesForPhotos > 0 {
                self.getPhotosRequest(lat: lat, lon: lon, pages: pagesForPhotos, context: context, pin: pin, afterRefresh: afterRefresh, completionHandlerForGetPhotosRequest: completionHandlerForGetPhotosForPageNumber)
                } else {
                    completionHandlerForGetPhotosForPageNumber(true, nil, nil)
                }
                
                
            } else {
                completionHandlerForGetPhotosForPageNumber(false, nil, NSError(domain: "getPhotosForPageNumber", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not get pages from getPhotosForPageNumber"]))
                
            }
        }
    }
    
    
    // Get page number for photos available from Flickr
    
    func getNumberOfPhotos(lat: Double, lon: Double, context: NSManagedObjectContext, pin: Pin, afterRefresh: Bool, completionHandlerForGetNumberOfPhotos: @escaping (Bool, Int?, NSError?) -> Void) {
        
        let paramaters: [String: String] = [
            ParamaterKeys.Method: ParamaterValues.PhotoSearchMethod,
            ParamaterKeys.ApiKey: ParamaterValues.ApiKey,
            ParamaterKeys.Latitude: "\(lat)",
            ParamaterKeys.Longitude: "\(lon)",
            ParamaterKeys.SafeSearch: ParamaterValues.SafeSearch,
            ParamaterKeys.Format: ParamaterValues.JsonFormat,
            ParamaterKeys.NoJsonCallBack: ParamaterValues.NoJsonCallBack,
            ParamaterKeys.Extras: "\(ParamaterValues.MediumURL),\(ParamaterValues.DateTaken)",
            ParamaterKeys.NumberPerPage: ParamaterValues.NumberOfPhotos
        ]
        
        taskForGetMethod(parameters: paramaters as [String : AnyObject]) { (result, error) in
            
            guard error == nil else {
                completionHandlerForGetNumberOfPhotos(false, nil, error)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandlerForGetNumberOfPhotos(false, nil, NSError(domain: "getNumberOfPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "No result from getNumberOfPhotos"]))
                return
            }
            
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                completionHandlerForGetNumberOfPhotos(false, nil, NSError(domain: "getNumberOfPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse getNumberOfPhotos"]))
                return
            }
            
            guard let pages = photosDictionary[ResponseKeys.NumberOfPages] as? Int else {
                completionHandlerForGetNumberOfPhotos(false, nil, NSError(domain: "getNumberOfPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not get numeber of pages from getNumberOfPhotos"]))
                return
            }
            
            completionHandlerForGetNumberOfPhotos(true, pages, nil)
        }

    }
    
    // Request to get photos from FLickr
    func getPhotosRequest(lat: Double, lon: Double, pages: Int, context: NSManagedObjectContext, pin: Pin, afterRefresh: Bool, completionHandlerForGetPhotosRequest: @escaping (Bool, [Photo]?, NSError?) -> Void) {
        
        var maxPages = 1
        if pages > 100 {
            maxPages = 100
        } else {
            maxPages = pages
        }
        
        let pagenumber = arc4random_uniform(UInt32(maxPages)) + 1
        
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
            
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse getPhotosRequest"]))
                return
            }
            
            guard let photosArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not get individual photos from photDictionary in getPhotosRequest"]))
                return
            }
            
            
            let photos = self.photosFromArray(photosArray: photosArray, context: context, pin: pin)
            
            completionHandlerForGetPhotosRequest(true, photos, nil)
            
        }
    }
    
    //MARK: - Response data helper methods
    
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
                print("Could not get photo properties from Json")
                return nil
        }
        
        if let photo = checkDuplicatePhoto(id: id, context: context) {
            photoToSave = photo
        } else {
            
            let date = formattedDate(dateToFormat: dateTaken)
            
            context.performAndWait() {
                photoToSave = Photo(inContext: context, date: date, id: id, title: title, url: urlString)
                photoToSave.pin = pin
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
        
    // Format date to Date type
    func formattedDate(dateToFormat: String) -> Date {
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let formattedDate = formatter.date(from: "\(dateToFormat)") {
            date = formattedDate
            
        } else {
            print("\n Could not get date from String \n ")
        }
        return date
    }
}
