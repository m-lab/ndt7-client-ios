//
//  Networking.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 5/15/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Protocol for URLSession dataTask
public protocol URLSessionNDT7 {
    associatedtype DataTaskType: URLSessionTaskNDT7
    func ndt7DataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> DataTaskType
}

/// Protocol for URLSessionTask
public protocol URLSessionTaskNDT7 {
    var state: URLSessionTask.State { get }
    func resume()
    func cancel()
}

extension URLSession: URLSessionNDT7 {
    public func ndt7DataTask(with request: URLRequest, completionHandler: @escaping @Sendable  (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    dataTask(with: request, completionHandler: completionHandler)
  }
}

extension URLSessionTask: URLSessionTaskNDT7 {
}

/// Networking helper methods.
class Networking: NSObject {

    static let shared = Networking()
    var session: URLSession!

    private override init() {
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    static func urlRequest(_ urlString: String) -> URLRequest {
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10
        return request as URLRequest
    }
}

extension Networking: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            challenge.protectionSpace.host == NDT7WebSocketConstants.MLabServerDiscover.hostname,
            let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
}
