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
    
    func taskForGetMethod (parameters: [String: AnyObject], completionHandlerForGet: (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        return
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
    
    private func requestSetup (url: URL, httpMethod: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = httpMethod
        
        return request
    }
    
    private func taskSetup (request: URLRequest, domain: String, completionHandlerForTask: @escaping (_ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let session = sharedSession
        let task = session.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
            
            self.checkErrors(domain: domain, data: data, error: error, response: response, completionHandler: completionHandlerForTask)
        }
        
        return task
    }
    
    //Check for errors
    private func checkErrors(domain: String, data: Data?, error: Error?, response: URLResponse?, completionHandler: @escaping (_ result: Any?, _ error: NSError?) -> Void) {
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandler(nil, NSError(domain: domain, code: 1, userInfo: userInfo))
        }
        
        guard (error == nil) else {
            sendError(error: "There was an error with the request: \(error)")
            return
        }
        
        guard let data = data else {
            sendError(error: "No data was returned by the request!")
            return
        }
        
        self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandler)
    }
    
    // Parse the data
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}
