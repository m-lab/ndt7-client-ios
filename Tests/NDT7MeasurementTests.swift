//
//  NDT7MeasurementTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
import NDT7

class NDT7MeasurementTests: XCTestCase {

    func testNDT7TestMeasurementCorrectJSON() {
        let measurementJSON = """
{
"elapsed": 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        do {
            let decoded = try JSONDecoder().decode(NDT7Measurement.self, from: measurementJSON.data(using: .utf8)!)
            XCTAssertEqual(decoded.elapsed, 1)
            XCTAssertEqual(decoded.tcpInfo?.smoothedRtt, 2)
            XCTAssertEqual(decoded.tcpInfo?.rttVar, 3)
            XCTAssertEqual(decoded.appInfo?.numBytes, 4)
            XCTAssertEqual(decoded.bbrInfo?.bandwith, 5)
            XCTAssertEqual(decoded.bbrInfo?.minRtt, 6)
        } catch {
            XCTFail("json not decoded")
        }
    }
}
