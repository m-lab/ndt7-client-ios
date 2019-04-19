//
//  NDT7TestTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class NDT7TestTests: XCTestCase {

    func testNdt7TestInstances() {
        var ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let instances = NDT7Test.ndt7TestInstances
        XCTAssertTrue(!instances.isEmpty)
        XCTAssertTrue(instances.contains(where: { $0.object === ndt7Test }))
        ndt7Test = nil
    }

    func testNDT7TestHhandleMessage() {
        let measurementJSON = """
{
"elapsed": 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let message = ndt7Test?.handleMessage(measurementJSON)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.elapsed, 1)
        XCTAssertEqual(message?.tcpInfo?.smoothedRtt, 2)
        XCTAssertEqual(message?.tcpInfo?.rttVar, 3)
        XCTAssertEqual(message?.appInfo?.numBytes, 4)
        XCTAssertEqual(message?.bbrInfo?.bandwith, 5)
        XCTAssertEqual(message?.bbrInfo?.minRtt, 6)
    }

    func testNDT7TestStartDownload() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.startDownload(false, { (error) in
            XCTAssertNil(error)
        })
    }

    func testNDT7TestStartUpload() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.startUpload(false, { (error) in
            XCTAssertNil(error)
        })
    }

    func testNDT7TestCancel() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.timerDownload = Timer(timeInterval: 1, repeats: false, block: { (_) in })
        ndt7Test?.timerUpload = Timer(timeInterval: 1, repeats: false, block: { (_) in })
        XCTAssertNotNil(ndt7Test?.timerDownload)
        XCTAssertNotNil(ndt7Test?.timerUpload)
        ndt7Test?.cancel()
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertNil(ndt7Test?.webSocketDownload)
        XCTAssertNil(ndt7Test?.webSocketUpload)
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
