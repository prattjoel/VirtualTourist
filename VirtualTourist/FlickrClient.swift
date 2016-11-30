//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joel on 11/10/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    let sharedSession = URLSession.shared
    
    // MARK: - Setup Task for GET requests
    func taskForGetMethod (parameters: [String: AnyObject], completionHandlerForGet: @escaping (AnyObject?, NSError?) -> Void) {
        let url = flickrURLFromParameters(parameters: parameters)
        print("URL for photos request is: \n \(url)")
        
        let request = requestSetup(url: url, httpMethod: "GET")
        let task = taskSetup(request: request, domain: "taskForGetMethod", completionHandlerForTask: completionHandlerForGet)
        
        task.resume()
    }
    
    private func flickrURLFromParameters(parameters: [String: AnyObject]?) -> URL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        
        if let params = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    private func requestSetup (url: URL, httpMethod: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        return request
    }
    
    private func taskSetup (request: URLRequest, domain: String, completionHandlerForTask: @escaping (AnyObject?, NSError?) -> Void) -> URLSessionDataTask {
        
        let session = sharedSession
        let task = session.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
            
            self.checkErrors(domain: domain, data: data, error: error, response: response, completionHandler: completionHandlerForTask)
        }
        
        return task
    }
    
    //Check for errors
    private func checkErrors(domain: String, data: Data?, error: Error?, response: URLResponse?, completionHandler: @escaping (AnyObject?, NSError?) -> Void) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandler(nil, NSError(domain: domain, code: 1, userInfo: userInfo))
        }
        
        guard (error == nil) else {
            sendError(error: "There was an error with the request: \(error)")
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            sendError(error: "The request returned a status code other than 200: \((response as? HTTPURLResponse)?.statusCode)")
            return
        }
        
        print("status code is: \n \(statusCode)")
        
        guard let data = data else {
            sendError(error: "No data was returned by the request!")
            return
        }
        
        self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandler)
    }
    
    // Parse the data
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (AnyObject?, NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // Create shared instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
