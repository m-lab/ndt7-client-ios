//
//  NDT7Settings.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/18/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Settings needed for NDT7.
public struct NDT7Settings {

    /// Server to connect.
    public let hostname: String

    /// Patch for download test.
    public let downloadPath: String

    /// Patch for upload test.
    public let uploadPath: String

    /// Define if it is wss or ws.
    public let wss: Bool

    /// Skipt TLS certificate verification.
    public let skipTLSCertificateVerification: Bool

    /// Define the interval between messages.
    public let measurementInterval: TimeInterval

    /// Timeout for connection.
    public let timeoutRequest: TimeInterval

    /// Define the max among of time used for a test before to force to finish.
    public let timeoutTest: TimeInterval

    /// Define all the headers needed for NDT7 communication.
    public let headers: [String: String]

    /// Initialization.
    public init(hostname: String = "35.235.104.27",
                downloadPath: String = "/ndt/v7/download",
                uploadPath: String = "/ndt/v7/upload",
                wss: Bool = true,
                skipTLSCertificateVerification: Bool = true,
                measurementInterval: TimeInterval = 0.25,
                timeoutRequest: TimeInterval = 5,
                timeoutTest: TimeInterval = 15,
                headers: [String: String] = ["Sec-WebSocket-Protocol": "net.measurementlab.ndt.v7",
                                             "Sec-WebSocket-Accept": "Nhz+x95YebD6Uvd4nqPC2fomoUQ=",
                                             "Sec-WebSocket-Version": "13",
                                             "Sec-WebSocket-Key": "DOdm+5/Cm3WwvhfcAlhJoQ=="]) {
        self.hostname = hostname
        self.downloadPath = downloadPath
        self.uploadPath = uploadPath
        self.wss = wss
        self.skipTLSCertificateVerification = skipTLSCertificateVerification
        self.measurementInterval = measurementInterval
        self.timeoutRequest = timeoutRequest
        self.timeoutTest = timeoutTest
        self.headers = headers
    }
}
