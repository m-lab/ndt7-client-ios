//
//  NDT7SettingsTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

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
        XCTAssertNil(defaultURL.server)
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

    func testDiscoverServer() {
        let defaultURL = NDT7URL(hostname: "")
        var result = false
        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = defaultURL.discoverServer(withGeoOptions: false) { (server, error) in
            XCTAssertNotNil(server)
            XCTAssertNotNil(server?.ip)
            XCTAssertNotNil(server?.city)
            XCTAssertNotNil(server?.country)
            XCTAssertNotNil(server?.fqdn)
            XCTAssertNotNil(server?.site)
            XCTAssertNil(error)
            result = true
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)
        var resultWithGeoOptions = false
        let expectationGeoOptions = XCTestExpectation(description: "Job in main thread")
        _ = defaultURL.discoverServer(withGeoOptions: false) { (server, error) in
            XCTAssertNotNil(server)
            XCTAssertNotNil(server?.ip)
            XCTAssertNotNil(server?.city)
            XCTAssertNotNil(server?.country)
            XCTAssertNotNil(server?.fqdn)
            XCTAssertNotNil(server?.site)
            XCTAssertNil(error)
            resultWithGeoOptions = true
            expectationGeoOptions.fulfill()
        }
        wait(for: [expectationGeoOptions], timeout: 10.0)
        XCTAssertTrue(resultWithGeoOptions)
        var resultWithTaskCancelled = false
        let expectationWithTaskCancelled = XCTestExpectation(description: "Job in main thread")
        let task = defaultURL.discoverServer(withGeoOptions: false) { (server, error) in
            XCTAssertNil(server)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, NDT7Constants.Test.cancelledError)
            resultWithTaskCancelled = true
            expectationWithTaskCancelled.fulfill()
        }
        task.cancel()
        wait(for: [expectationWithTaskCancelled], timeout: 10.0)
        XCTAssertTrue(resultWithTaskCancelled)
    }

    func testDecodeServer() {
        let jsonServer = """
{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}
"""
        let server = NDT7URL.decodeServer(data: jsonServer.data(using: .utf8), fromUrl: NDT7Constants.MlabServerDiscover.url)
        XCTAssertTrue(server!.ip!.contains("70.42.177.114"))
        XCTAssertTrue(server!.ip!.contains("2600:c0b:2002:5::114"))
        XCTAssertEqual(server?.country, "US")
        XCTAssertEqual(server?.city, "Atlanta_GA")
        XCTAssertEqual(server?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(server?.site, "atl06")
        let jsonServerList = """
[{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}]
"""
        let serverFromList = NDT7URL.decodeServer(data: jsonServerList.data(using: .utf8), fromUrl: NDT7Constants.MlabServerDiscover.urlWithGeoOption)
        XCTAssertTrue(serverFromList!.ip!.contains("70.42.177.114"))
        XCTAssertTrue(serverFromList!.ip!.contains("2600:c0b:2002:5::114"))
        XCTAssertEqual(serverFromList?.country, "US")
        XCTAssertEqual(serverFromList?.city, "Atlanta_GA")
        XCTAssertEqual(serverFromList?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverFromList?.site, "atl06")
        let noServerFromList = NDT7URL.decodeServer(data: jsonServerList.data(using: .utf8), fromUrl: "empty")
        XCTAssertNil(noServerFromList)
    }
}
