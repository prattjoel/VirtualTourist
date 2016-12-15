//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Joel on 11/10/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // MARK: - Flickr Constants
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct ParamaterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let SafeSearch = "safe_search"
        static let Format = "format"
        static let NoJsonCallBack = "nojsoncallback"
        static let Extras = "extras"
        static let NumberPerPage = "per_page"
        static let PageNumber = "page"
    }
    
    struct ParamaterValues {
        static let PhotoSearchMethod = "flickr.photos.search"
        static let ApiKey = "6b7fd48fed0faa69649860e4eaead7fa"
        static let SafeSearch = "1"
        static let JsonFormat = "json"
        static let NoJsonCallBack = "1"
        static let MediumURL = "url_m"
        static let DateTaken = "date_taken"
        static let NumberOfPhotos = "20"
    }
    
    struct ResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Url = "url_m"
        static let Date = "datetaken"
        static let ID = "id"
        static let Title = "title"
        static let Page = "page"
        static let Total = "total"
        static let NumberOfPages = "pages"
    }
}
