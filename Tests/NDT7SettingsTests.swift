//
//  NDT7SettingsTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class URLSessionMock: URLSessionNDT7 {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    typealias URLSessionTaskNDT7 = URLSessionDataTaskMock
    var data: Data?
    var error: Error?
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionTaskNDT7 {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class URLSessionDataTaskMock: URLSessionTaskNDT7 {
    private let closure: () -> Void
    var state: URLSessionTask.State
    init(closure: @escaping () -> Void) {
        self.closure = closure
        self.state = .running
    }
    func resume() {
        closure()
    }
    func cancel() {
        closure()
    }
}

class NDT7SettingsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NDT7Server.lastServer = nil
    }

    override func tearDown() {
        NDT7Server.lastServer = nil
        super.tearDown()
    }

    func testNDT7SettingsDefault() {
        let defaultSettings = NDT7Settings()
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
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
        XCTAssertEqual(defaultTimeouts.ioTimeout, 7)
        XCTAssertEqual(defaultTimeouts.downloadTimeout, 15)
        XCTAssertEqual(defaultTimeouts.uploadTimeout, 15)
    }

    func testDiscoverServer() {

        // 1. The server is discovered without geo options enabled (NDT7 server cache disabled).
        let session = URLSessionMock()
        let jsonServerData = """
        {\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}
        """.data(using: .utf8)
        session.data = jsonServerData
        var result = false
        var serverResult: NDT7Server?
        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                withGeoOptions: false,
                                retray: 100,
                                geoOptionsChangeInRetray: false, { (server, _) in
                                    serverResult = server
                                    result = true
                                    expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)
        XCTAssertNotNil(serverResult)
        XCTAssertTrue(serverResult?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(serverResult?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(serverResult?.country, "US")
        XCTAssertEqual(serverResult?.city, "Atlanta_GA")
        XCTAssertEqual(serverResult?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverResult?.site, "atl06")

        // 2. The server is discovered with geo options enabled (NDT7 server cache disabled).
        let jsonServerListData1 = """
        [{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}]
        """.data(using: .utf8)
        session.data = jsonServerListData1
        var resultWithGeoOptions1 = false
        let expectationGeoOptions1 = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                withGeoOptions: true,
                                retray: 100,
                                geoOptionsChangeInRetray: false, { (server, _) in
                                    serverResult = server
                                    resultWithGeoOptions1 = true
                                    expectationGeoOptions1.fulfill()
        })
        wait(for: [expectationGeoOptions1], timeout: 10.0)
        XCTAssertTrue(resultWithGeoOptions1)
        XCTAssertNotNil(serverResult)
        XCTAssertTrue(serverResult?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(serverResult?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(serverResult?.country, "US")
        XCTAssertEqual(serverResult?.city, "Atlanta_GA")
        XCTAssertEqual(serverResult?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverResult?.site, "atl06")

        // 3. if there is an error getting a new server, the server can't be discovered (NDT7 server cache disabled).
        let jsonServerListData3 = """
        [{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"site\": \"atl06\"}]
        """.data(using: .utf8)
        session.data = jsonServerListData3
        var resultWithGeoOptions3 = false
        let expectationGeoOptions3 = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                withGeoOptions: true,
                                retray: 100,
                                geoOptionsChangeInRetray: false, { (server, _) in
                                    serverResult = server
                                    resultWithGeoOptions3 = true
                                    expectationGeoOptions3.fulfill()
        })
        wait(for: [expectationGeoOptions3], timeout: 10.0)
        XCTAssertTrue(resultWithGeoOptions3)
        XCTAssertNil(serverResult)
    }

    func testDiscoverServerUsingNDT7ServerCache() {

        // The server is discovered without geo options enabled and saved in cache.
        let session = URLSessionMock()
        let jsonServerData = """
        {\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}
        """.data(using: .utf8)
        session.data = jsonServerData
        var result = false
        var serverResult: NDT7Server?
        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                withGeoOptions: false,
                                retray: 100,
                                geoOptionsChangeInRetray: false, { (server, _) in
                                    serverResult = server
                                    result = true
                                    expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)
        XCTAssertNotNil(serverResult)
        XCTAssertTrue(serverResult?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(serverResult?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(serverResult?.country, "US")
        XCTAssertEqual(serverResult?.city, "Atlanta_GA")
        XCTAssertEqual(serverResult?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverResult?.site, "atl06")

        // If the server discovery is returning errors, the discovery returns the last server discovered if getting the server in cache is enabled.
        let jsonServerListData5 = """
        """.data(using: .utf8)
        session.data = jsonServerListData5
        session.error = NDT7WebSocketConstants.MlabServerDiscover.noMlabServerError
        var errorResult: Error?
        var resultWithGeoOptions5 = false
        let expectationGeoOptions5 = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                withGeoOptions: true,
                                retray: 100,
                                geoOptionsChangeInRetray: false,
                                useNDT7ServerCache: true, { (server, error) in
                                    errorResult = error
                                    serverResult = server
                                    resultWithGeoOptions5 = true
                                    expectationGeoOptions5.fulfill()
        })
        wait(for: [expectationGeoOptions5], timeout: 10.0)
        XCTAssertTrue(resultWithGeoOptions5)
        XCTAssertNotNil(serverResult)
        XCTAssertNil(errorResult)
        XCTAssertTrue(serverResult?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(serverResult?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(serverResult?.country, "US")
        XCTAssertEqual(serverResult?.city, "Atlanta_GA")
        XCTAssertEqual(serverResult?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverResult?.site, "atl06")
    }

    func testDecodeServer() {
        let jsonServer = """
{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}
"""
        let server = NDT7Server.decode(data: jsonServer.data(using: .utf8), fromUrl: NDT7WebSocketConstants.MlabServerDiscover.url)
        XCTAssertTrue(server?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(server?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(server?.country, "US")
        XCTAssertEqual(server?.city, "Atlanta_GA")
        XCTAssertEqual(server?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(server?.site, "atl06")
        let jsonServerList = """
[{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"fqdn\": \"ndt-iupui-mlab4-atl06.measurement-lab.org\", \"site\": \"atl06\"}]
"""
        let serverFromList = NDT7Server.decode(data: jsonServerList.data(using: .utf8), fromUrl: NDT7WebSocketConstants.MlabServerDiscover.urlWithGeoOption)
        XCTAssertTrue(serverFromList?.ip?.contains("70.42.177.114") != nil)
        XCTAssertTrue(serverFromList?.ip?.contains("2600:c0b:2002:5::114") != nil)
        XCTAssertEqual(serverFromList?.country, "US")
        XCTAssertEqual(serverFromList?.city, "Atlanta_GA")
        XCTAssertEqual(serverFromList?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
        XCTAssertEqual(serverFromList?.site, "atl06")
        let noServerFromList = NDT7Server.decode(data: jsonServerList.data(using: .utf8), fromUrl: "empty")
        XCTAssertNil(noServerFromList)
    }
}
