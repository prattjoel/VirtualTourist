//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Joel on 11/14/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotosRequest(lat: Float, lon: Float, completionHandlerForGetPhotosRequest: @escaping (Bool, [String: AnyObject]?, NSError?) -> Void) {
        
        let paramaters: [String: String] = [
            ParamaterKeys.Method: ParamaterValues.PhotoSearchMethod,
            ParamaterKeys.ApiKey: ParamaterValues.ApiKey,
            ParamaterKeys.Latitude: "\(lat)",
            ParamaterKeys.Longitude: "\(lon)",
            ParamaterKeys.SafeSearch: ParamaterValues.SafeSearch,
            ParamaterKeys.Format: ParamaterValues.JsonFormat,
            ParamaterKeys.NoJsonCallBack: ParamaterValues.NoJsonCallBack
        ]
        
        taskForGetMethod(parameters: paramaters as [String : AnyObject]) { (result, error) in
            
            guard error == nil else {
                completionHandlerForGetPhotosRequest(false, nil, error)
                return
            }
            
            guard let result = result else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "No result from getPhotosRequest"]))
                return
            }
            
            print("Result from photos request: \n \(result)")
            
            guard let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject] else {
                completionHandlerForGetPhotosRequest(false, nil, NSError(domain: "getPhotosRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not parse getPhotosRequest"]))
                return
            }
            
            //print("\(photosDictionary)")
            
            completionHandlerForGetPhotosRequest(true, photosDictionary, nil)
            
        }
    }
}
