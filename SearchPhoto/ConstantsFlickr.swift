//
//  ConstantsFlickr.swift
//  SearchPhoto
//
//  Created by Andrey Alhimchenkov on 11/3/19.
//  Copyright © 2019 Andrey Alhimchenkov. All rights reserved.
//

import Foundation

struct Constants {
    
    struct APIValStr {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "490a09bc94268b2dbc9bc5780507de9c"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
    }
    
    struct URLParamStr {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
    }
    
    struct APIKeyStr {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let DisableJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
    }
    


}
