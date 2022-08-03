//
//  NDT7Settings.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/18/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Settings needed for NDT7.
/// Can be used with default values: NDT7Settings()
public struct NDT7Settings {

    /// Timeouts
    public let timeout: NDT7Timeouts

    /// Skip TLS certificate verification.
    public let skipTLSCertificateVerification: Bool

    /// Define all the headers needed for NDT7 request.
    public let headers: [String: String]

    /// MLab servers returned from Locate V2 API that will be used to run the speed test.
    public var allServers: [NDT7Server] = []

    /// Index of the server in `allServers` array that will be used for the test.
    public var currentServerIndex: Int?

    /// MLab server that will be used to perform a speed test.
    public var currentServer: NDT7Server? {
        guard let selectedIndex = currentServerIndex,
              selectedIndex < allServers.count else { return nil }
        return allServers[selectedIndex]
    }

    /// URL to use to run download speed test.
    public var currentDownloadURL: URL? {
        guard let downloadPath = currentServer?.urls.downloadPath else { return nil }
        return URL(string: downloadPath)
    }

    /// URL to use to run upload speed test.
    public var currentUploadURL: URL? {
        guard let uploadPath = currentServer?.urls.uploadPath else { return nil }
        return URL(string: uploadPath)
    }

    /// Initialization.
    public init(timeout: NDT7Timeouts = NDT7Timeouts(),
                skipTLSCertificateVerification: Bool = false,
                headers: [String: String] = [NDT7WebSocketConstants.Request.headerProtocolKey: NDT7WebSocketConstants.Request.headerProtocolValue]) {
        self.skipTLSCertificateVerification = skipTLSCertificateVerification
        self.timeout = timeout
        self.headers = headers
    }
}

/// Timeout settings.
public struct NDT7Timeouts {

    /// Define the interval between messages.
    /// When downloading, the server is expected to send measurement to the client,
    /// and when uploading, conversely, the client is expected to send measurements to the server.
    /// Measurements SHOULD NOT be sent more frequently than every 250 ms
    /// This parameter deine the frequent to send messages.
    /// If it is initialize with less than 250 ms, it's going to be overwritten to 250 ms
    public let measurement: TimeInterval

    /// ioTimeout is the timeout in seconds for I/O operations.
    public let ioTimeout: TimeInterval

    /// Define the max among of time used for a download test before to force to finish.
    public let downloadTimeout: TimeInterval

    /// Define the max among of time used for a upload test before to force to finish.
    public let uploadTimeout: TimeInterval

    /// Initialization.
    public init(measurement: TimeInterval = NDT7WebSocketConstants.Request.updateInterval,
                ioTimeout: TimeInterval = NDT7WebSocketConstants.Request.ioTimeout,
                downloadTimeout: TimeInterval = NDT7WebSocketConstants.Request.downloadTimeout,
                uploadTimeout: TimeInterval = NDT7WebSocketConstants.Request.uploadTimeout) {
        self.measurement = measurement >= NDT7WebSocketConstants.Request.updateInterval ? measurement : NDT7WebSocketConstants.Request.updateInterval
        self.ioTimeout = ioTimeout
        self.downloadTimeout = downloadTimeout
        self.uploadTimeout = uploadTimeout
    }
}

/// Locate API V2 response object
public struct LocateAPIResponse: Codable {
    public var results: [NDT7Server]
}

/// Locate API V2 MLab NDT7 Server.
public struct NDT7Server: Codable {

    /// The URL of the machine.
    public var machine: String

    /// Location of the server.
    public var location: NDT7Location?

    /// URLS from which the client can upload/download.
    public var urls: NDT7URLs
}

/// Locate API V2 Location that describes geographic location of the target server.
public struct NDT7Location: Codable {
    /// Country of the target server.
    public var country: String?

    /// City of the target server.
    public var city: String?
}

/// Locate API V2 URLs.
/// This struct contains the complete download/upload URL for running a measurement.
public struct NDT7URLs: Codable {
    /// Complete path to server to test download speed.
    /// The path uses wss:// protocol (encrypted connection) and auth token.
    public var downloadPath: String

    /// Complete path to server to test upload speed.
    /// The path uses wss:// protocol (encrypted connection) and auth token.
    public var uploadPath: String

    /// Complete path to server to test download speed.
    /// The path uses ws:// protocol scheme (unencrypted connection) and auth token.
    public var insecureDownloadPath: String

    /// Complete path to server to test upload speed.
    /// The path uses ws:// protocol (unencrypted connection) and auth token.
    public var insecureUploadPath: String

    enum CodingKeys: String, CodingKey {
        case downloadPath = "wss:///ndt/v7/download"
        case uploadPath = "wss:///ndt/v7/upload"
        case insecureDownloadPath = "ws:///ndt/v7/download"
        case insecureUploadPath = "ws:///ndt/v7/upload"
    }
}

/// This extension provides helper methods to discover MLab servers availables.
extension NDT7Server {

    /// Discover the closer MLab server available or using geo location to get a random server from a list of the closer servers.
    /// - parameter session: URLSession object used to request servers, using URLSession.shared object as default session.
    /// - parameter retry: Number of times to retry.
    /// - parameter completion: callback to get the NDT7Server and error message.
    /// - parameter servers: An array of NDT7Server objects representing the MLab servers located nearby.
    /// - parameter error: if any error happens, this parameter returns the error.
    public static func discover<T: URLSessionNDT7>(session: T = URLSession.shared as! T,
                                                   retry: UInt = 0,
                                                   _ completion: @escaping (_ server: [NDT7Server]?, _ error: NSError?) -> Void) -> URLSessionTaskNDT7 {
        let retry = min(retry, 4)
        let request = Networking.urlRequest(NDT7WebSocketConstants.MLabServerDiscover.url)
        let task = session.ndt7DataTask(with: request as URLRequest) { (data, _, error) -> Void in
            OperationQueue.current?.name = "net.measurementlab.NDT7.MlabServer.discover"
            guard error?.localizedDescription != "cancelled" else {
                completion(nil, NDT7TestConstants.cancelledError)
                return
            }
            guard error == nil, let data = data else {
                if retry > 0 {
                    logNDT7("NDT7 MLab cannot find a suitable MLab server, retry: \(retry)", .info)
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        _ = discover(session: session, retry: retry - 1, completion)
                    }
                } else {
                    completion(nil, NDT7WebSocketConstants.MLabServerDiscover.noMLabServerError)
                }
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(LocateAPIResponse.self, from: data)
                completion(apiResponse.results, nil)
            } catch let jsonError as NSError {
                logNDT7("JSON decode failed: \(jsonError.localizedDescription)")
                completion(nil, NDT7WebSocketConstants.MLabServerDiscover.noMLabServerError)
            }

            return
        }
        task.resume()
        return task
    }
}
