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
        XCTAssertEqual(NDT7TestConstants.cancelled, "Test cancelled")
        XCTAssertEqual(NDT7TestConstants.Origin.client.rawValue, "client")
        XCTAssertEqual(NDT7TestConstants.Origin.server.rawValue, "server")
        XCTAssertEqual(NDT7TestConstants.Kind.download.rawValue, "download")
        XCTAssertEqual(NDT7TestConstants.Kind.upload.rawValue, "upload")
        XCTAssertEqual(NDT7WebSocketConstants.domain, "net.measurementlab.NDT7")
        XCTAssertEqual(NDT7WebSocketConstants.MLabServerDiscover.hostname, "locate.measurementlab.net")
        XCTAssertEqual(NDT7WebSocketConstants.MLabServerDiscover.path, "v2/nearest/ndt/ndt7")
        XCTAssertEqual(NDT7WebSocketConstants.MLabServerDiscover.hostname, "locate.measurementlab.net")
        XCTAssertEqual(NDT7WebSocketConstants.MLabServerDiscover.hostname, "locate.measurementlab.net")
        XCTAssertEqual(NDT7WebSocketConstants.MLabServerDiscover.hostname, "locate.measurementlab.net")
        XCTAssertEqual(NDT7WebSocketConstants.Request.headerProtocolKey, "Sec-WebSocket-Protocol")
        XCTAssertEqual(NDT7WebSocketConstants.Request.headerProtocolValue, "net.measurementlab.ndt.v7")
        XCTAssertEqual(NDT7WebSocketConstants.Request.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(NDT7WebSocketConstants.Request.uploadPath, "/ndt/v7/upload")
        XCTAssertEqual(NDT7WebSocketConstants.Request.downloadTimeout, 15)
        XCTAssertEqual(NDT7WebSocketConstants.Request.uploadTimeout, 15)
        XCTAssertEqual(NDT7WebSocketConstants.Request.ioTimeout, 7)
        XCTAssertEqual(NDT7WebSocketConstants.Request.updateInterval, 0.25)
        XCTAssertEqual(NDT7WebSocketConstants.Request.bulkMessageSize, 1 << 13)
    }
}
