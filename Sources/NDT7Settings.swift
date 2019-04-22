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
    public let url: NDT7URL

    /// Timeouts
    public let timeout: NDT7Timeouts

    /// Skipt TLS certificate verification.
    public let skipTLSCertificateVerification: Bool

    /// Define all the headers needed for NDT7 request.
    public let headers: [String: String]

    /// Initialization.
    public init(url: NDT7URL = NDT7URL(),
                timeout: NDT7Timeouts = NDT7Timeouts(),
                skipTLSCertificateVerification: Bool = true,
                headers: [String: String] = [NDT7WebSocketConstants.headerProtocolKey: NDT7WebSocketConstants.headerProtocolValue,
                                             NDT7WebSocketConstants.headerAcceptKey: NDT7WebSocketConstants.headerAcceptValue,
                                             NDT7WebSocketConstants.headerVersionKey: NDT7WebSocketConstants.headerVersionValue,
                                             NDT7WebSocketConstants.headerKey: NDT7WebSocketConstants.headerValue]) {
        self.url = url
        self.skipTLSCertificateVerification = skipTLSCertificateVerification
        self.timeout = timeout
        self.headers = headers
    }
}

/// URL settings.
public struct NDT7URL {

    /// Server to connect.
    public let hostname: String

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
    public init(hostname: String = NDT7WebSocketConstants.hostname,
                downloadPath: String = NDT7WebSocketConstants.downloadPath,
                uploadPath: String = NDT7WebSocketConstants.uploadPath,
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
