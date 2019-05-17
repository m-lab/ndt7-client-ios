//
//  Networking.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 5/15/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Networking helper methods.
struct Networking {

    static func urlRequest(_ urlString: String) -> URLRequest {
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10
        return request as URLRequest
    }
}
