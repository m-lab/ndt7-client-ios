//
//  NDT7SettingsTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
import NDT7

class NDT7SettingsTests: XCTestCase {

    func testNDT7SettingsDefault() {
        let defaultSettings = NDT7Settings()
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Accept"], "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Version"], "13")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Key"], "DOdm+5/Cm3WwvhfcAlhJoQ==")
    }

    func testNDT7URLDefault() {
        let defaultURL = NDT7URL(hostname: "")
        XCTAssertEqual(defaultURL.hostname, "")
        XCTAssertEqual(defaultURL.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(defaultURL.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(defaultURL.wss)
        XCTAssertEqual(defaultURL.download, "wss:///ndt/v7/download")
        XCTAssertEqual(defaultURL.upload, "wss:///ndt/v7/upload")
    }

    func testNDT7TimeoutsDefault() {
        let defaultTimeouts = NDT7Timeouts()
        XCTAssertEqual(defaultTimeouts.measurement, 0.25)
        XCTAssertEqual(defaultTimeouts.request, 5)
        XCTAssertEqual(defaultTimeouts.test, 15)
    }
}
