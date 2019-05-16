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

    /// URL for Web Socket.
    public var url: NDT7URL

    /// Timeouts
    public let timeout: NDT7Timeouts

    /// Skipt TLS certificate verification.
    public let skipTLSCertificateVerification: Bool

    /// Use geo options to get a list of Mlab servers vs the closer one with false.
    public let useGeoOptions: Bool

    /// Define all the headers needed for NDT7 request.
    public let headers: [String: String]

    /// Initialization.
    public init(url: NDT7URL = NDT7URL(hostname: ""),
                timeout: NDT7Timeouts = NDT7Timeouts(),
                skipTLSCertificateVerification: Bool = true,
                useGeoOptions: Bool = false,
                headers: [String: String] = [NDT7Constants.WebSocket.headerProtocolKey: NDT7Constants.WebSocket.headerProtocolValue,
                                     NDT7Constants.WebSocket.headerAcceptKey: NDT7Constants.WebSocket.headerAcceptValue,
                                     NDT7Constants.WebSocket.headerVersionKey: NDT7Constants.WebSocket.headerVersionValue,
                                     NDT7Constants.WebSocket.headerKey: NDT7Constants.WebSocket.headerValue]) {
        self.url = url
        self.skipTLSCertificateVerification = skipTLSCertificateVerification
        self.useGeoOptions = useGeoOptions
        self.timeout = timeout
        self.headers = headers
    }
}

/// URL settings.
public struct NDT7URL {

    /// Mlab Server:
    public var server: NDT7Server?

    /// Server to connect.
    public var hostname: String

    /// Patch for download test.
    public let downloadPath: String

    /// Patch for upload test.
    public let uploadPath: String

    /// Define if it is wss or ws.
    public let wss: Bool

    /// Download URL
    public var download: String {
        return "\(wss ? "wss" : "ws")\("://")\(hostname)\(downloadPath)"
    }

    /// Upload URL
    public var upload: String {
        return "\(wss ? "wss" : "ws")\("://")\(hostname)\(uploadPath)"
    }

    /// Initialization.
    public init(hostname: String,
                downloadPath: String = NDT7Constants.WebSocket.downloadPath,
                uploadPath: String = NDT7Constants.WebSocket.uploadPath,
                wss: Bool = true) {
        self.hostname = hostname
        self.downloadPath = downloadPath
        self.uploadPath = uploadPath
        self.wss = wss
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

    /// Timeout for connection.
    public let request: TimeInterval

    /// Define the max among of time used for a test before to force to finish.
    public let test: TimeInterval

    /// Initialization.
    public init(measurement: TimeInterval = 0.25,
                request: TimeInterval = 5,
                test: TimeInterval = 15) {
        self.measurement = measurement >= 0.25 ? measurement : 0.25
        self.request = request
        self.test = test
    }
}

/// Mlab NDT7 Server.
public struct NDT7Server: Codable {

    /// ip array
    public var ip: [String]?

    /// country
    public var country: String?

    /// city
    public var city: String?

    /// fqdn
    public var fqdn: String?

    /// site
    public var site: String?
}

/// This extension provides helper methods to discover Mlab servers availables.
extension NDT7URL {

    /// Discover the closer Mlab server available or using geo location to get a random server from a list of the closer servers if hostname is empty.
    /// - parameter geoOptions: true to use a list of servers based in geo location, otherwise the function will work trying to get the closer server.
    /// - parameter completion: callback to get the NDT7Server and error message.
    /// - parameter server: NDT7Server object representing the Mlab server.
    /// - parameter error: if any error happens, this parameter returns the error.
    public func discoverServer(withGeoOptions geoOptions: Bool, _ completion: @escaping (_ server: NDT7Server?, _ error: NSError?) -> Void) {
        let session = URLSession.shared
        let request = Networking.urlRequest(geoOptions ? NDT7Constants.MlabServerDiscover.urlWithGeoOption : NDT7Constants.MlabServerDiscover.url)
        let task = session.dataTask(with: request as URLRequest) { (data, _, error) -> Void in
            OperationQueue.current?.name = "net.measurementlab.NDT7.MlabServer.Setup"
            let server = NDT7URL.decodeServer(data: data, fromUrl: request.url?.absoluteString)
            logNDT7("NDT7 Mlab server \(server?.fqdn ?? "")\(error == nil ? "" : " error: \(error!.localizedDescription)")", .info)
            completion(server, server?.fqdn == nil ? NDT7Constants.MlabServerDiscover.noMlabServerError : nil)
        }
        task.resume()
    }

    static func decodeServer(data: Data?, fromUrl url: String?) -> NDT7Server? {
        guard let data = data, let url = url else { return nil }
        switch url {
        case NDT7Constants.MlabServerDiscover.url:
            return try? JSONDecoder().decode(NDT7Server.self, from: data)
        case NDT7Constants.MlabServerDiscover.urlWithGeoOption:
            let decoded = try? JSONDecoder().decode([NDT7Server].self, from: data)
            let server = decoded?.first(where: { (server) -> Bool in
                return server.fqdn != nil && !server.fqdn!.isEmpty
            })
            return server
        default:
            return nil
        }
    }
}
