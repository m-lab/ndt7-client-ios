//
//  NDT7MeasurementTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class NDT7MeasurementTests: XCTestCase {

    func testNDT7TestMeasurementCorrectJSON() {
        let measurementJSON = """
{
 "AppInfo": {
   "ElapsedTime": 12341,
   "NumBytes": 12342,
 },
 "BBRInfo": {
   "ElapsedTime": 123,
   "BW": 456,
   "MinRTT": 789,
   "CwndGain":739,
   "PacingGain":724
 },
"ConnectionInfo": {
  "Client": "1.2.3.4:5678",
  "Server": "[::1]:2345",
  "UUID": "<platform-specific-string>"
},
 "Origin": "server",
 "Test": "download",
 "TCPInfo": {
   "BusyTime": 1234,
   "BytesAcked": 12345,
   "BytesReceived": 12346,
   "BytesSent": 12347,
   "BytesRetrans": 12348,
   "ElapsedTime": 12349,
   "MinRTT": 12340,
   "RTT": 123411,
   "RTTVar": 123412,
   "RWndLimited": 123413,
   "SndBufLimited": 123414
 }
}
"""
        do {
            let decoded = try JSONDecoder().decode(NDT7Measurement.self, from: measurementJSON.data(using: .utf8)!)
            XCTAssertEqual(decoded.appInfo?.elapsedTime, 12341)
            XCTAssertEqual(decoded.appInfo?.numBytes, 12342)
            XCTAssertEqual(decoded.connectionInfo?.client, "1.2.3.4:5678")
            XCTAssertEqual(decoded.connectionInfo?.server, "[::1]:2345")
            XCTAssertEqual(decoded.connectionInfo?.uuid, "<platform-specific-string>")
            XCTAssertEqual(decoded.connectionInfo?.uuid, "<platform-specific-string>")
            XCTAssertEqual(decoded.bbrInfo?.elapsedTime, 123)
            XCTAssertEqual(decoded.bbrInfo?.bandwith, 456)
            XCTAssertEqual(decoded.bbrInfo?.minRtt, 789)
            XCTAssertEqual(decoded.bbrInfo?.cwndGain, 739)
            XCTAssertEqual(decoded.bbrInfo?.pacingGain, 724)
            XCTAssertEqual(decoded.origin, .server)
            XCTAssertEqual(decoded.direction, .download)
            XCTAssertEqual(decoded.tcpInfo?.busyTime, 1234)
            XCTAssertEqual(decoded.tcpInfo?.bytesAcked, 12345)
            XCTAssertEqual(decoded.tcpInfo?.bytesReceived, 12346)
            XCTAssertEqual(decoded.tcpInfo?.bytesSent, 12347)
            XCTAssertEqual(decoded.tcpInfo?.bytesRetrans, 12348)
            XCTAssertEqual(decoded.tcpInfo?.elapsedTime, 12349)
            XCTAssertEqual(decoded.tcpInfo?.minRTT, 12340)
            XCTAssertEqual(decoded.tcpInfo?.rtt, 123411)
            XCTAssertEqual(decoded.tcpInfo?.rttVar, 123412)
            XCTAssertEqual(decoded.tcpInfo?.rwndLimited, 123413)
            XCTAssertEqual(decoded.tcpInfo?.sndBufLimited, 123414)
        } catch {
            XCTFail("json not decoded")
        }
    }
}
