//
//  ConstantsTests.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/23/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
import NDT7

class ConstantsTests: XCTestCase {

    func testNDT7Constants() {
        XCTAssertEqual(NDT7Constants.domain, "net.measurementlab.NDT7")
        XCTAssertEqual(NDT7Constants.WebSocket.hostname, "ndt-iupui-mlab4-lax04.measurement-lab.org")
        XCTAssertEqual(NDT7Constants.WebSocket.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(NDT7Constants.WebSocket.uploadPath, "/ndt/v7/upload")
        XCTAssertEqual(NDT7Constants.WebSocket.headerProtocolKey, "Sec-WebSocket-Protocol")
        XCTAssertEqual(NDT7Constants.WebSocket.headerProtocolValue, "net.measurementlab.ndt.v7")
        XCTAssertEqual(NDT7Constants.WebSocket.headerAcceptKey, "Sec-WebSocket-Accept")
        XCTAssertEqual(NDT7Constants.WebSocket.headerAcceptValue, "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(NDT7Constants.WebSocket.headerVersionKey, "Sec-WebSocket-Version")
        XCTAssertEqual(NDT7Constants.WebSocket.headerVersionValue, "13")
        XCTAssertEqual(NDT7Constants.WebSocket.headerKey, "Sec-WebSocket-Key")
        XCTAssertEqual(NDT7Constants.WebSocket.headerValue, "DOdm+5/Cm3WwvhfcAlhJoQ==")
        XCTAssertEqual(NDT7Constants.Test.cancelled, "Test cancelled")
    }
}
