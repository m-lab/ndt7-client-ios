//
//  NDT7Settings.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/18/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

public struct NDT7Settings {
    public let hostname: String
    public let downloadPath: String
    public let uploadPath: String
    public let wss: Bool
    public let skipTLSCertificateVerification: Bool
    public let measurementInterval: TimeInterval
    public let timeoutRequest: TimeInterval
    public let timeoutTest: TimeInterval
    public let headers: [String: String]
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
