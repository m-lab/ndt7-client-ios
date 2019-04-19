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

    func testNDT7SettingsDefaultValues() {
        let defaultSettings = NDT7Settings()
        XCTAssertEqual(defaultSettings.hostname, "35.235.104.27")
        XCTAssertEqual(defaultSettings.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(defaultSettings.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(defaultSettings.wss)
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.measurementInterval, 0.25)
        XCTAssertEqual(defaultSettings.timeoutRequest, 5)
        XCTAssertEqual(defaultSettings.timeoutTest, 15)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Accept"], "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Version"], "13")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Key"], "DOdm+5/Cm3WwvhfcAlhJoQ==")
    }
    func testNDT7SettingsMeasurementIntervalMinimum() {
        let defaultSettings = NDT7Settings(measurementInterval: 0.1)
        XCTAssertEqual(defaultSettings.hostname, "35.235.104.27")
        XCTAssertEqual(defaultSettings.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(defaultSettings.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(defaultSettings.wss)
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.measurementInterval, 0.25)
        XCTAssertEqual(defaultSettings.timeoutRequest, 5)
        XCTAssertEqual(defaultSettings.timeoutTest, 15)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Accept"], "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Version"], "13")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Key"], "DOdm+5/Cm3WwvhfcAlhJoQ==")
    }
    func testNDT7SettingsMeasurementInterval() {
        let defaultSettings = NDT7Settings(measurementInterval: 5.5)
        XCTAssertEqual(defaultSettings.hostname, "35.235.104.27")
        XCTAssertEqual(defaultSettings.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(defaultSettings.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(defaultSettings.wss)
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.measurementInterval, 5.5)
        XCTAssertEqual(defaultSettings.timeoutRequest, 5)
        XCTAssertEqual(defaultSettings.timeoutTest, 15)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Accept"], "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Version"], "13")
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Key"], "DOdm+5/Cm3WwvhfcAlhJoQ==")
    }
}
