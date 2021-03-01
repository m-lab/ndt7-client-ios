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
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNDT7SettingsDefault() {
        let defaultSettings = NDT7Settings()
        XCTAssertTrue(defaultSettings.skipTLSCertificateVerification)
        XCTAssertEqual(defaultSettings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
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
        var serversResult: [NDT7Server]?
        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                retry: 100, { (servers, _) in
                                    serversResult = servers
                                    result = true
                                    expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)
        XCTAssertNotNil(serversResult)
//        XCTAssertTrue(serverResult?.ip?.contains("70.42.177.114") != nil)
//        XCTAssertTrue(serverResult?.ip?.contains("2600:c0b:2002:5::114") != nil)
//        XCTAssertEqual(serverResult?.country, "US")
//        XCTAssertEqual(serverResult?.city, "Atlanta_GA")
//        XCTAssertEqual(serverResult?.fqdn, "ndt-iupui-mlab4-atl06.measurement-lab.org")
//        XCTAssertEqual(serverResult?.site, "atl06")

        // 2. if there is an error getting a new server, the server can't be discovered.
        let jsonServerListData2 = """
        [{\"ip\": [\"70.42.177.114\", \"2600:c0b:2002:5::114\"], \"country\": \"US\", \"city\": \"Atlanta_GA\", \"site\": \"atl06\"}]
        """.data(using: .utf8)
        session.data = jsonServerListData2
        let expectationGeoOptions2 = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                retry: 100, { (server, _) in
                                    serversResult = server
                                    expectationGeoOptions2.fulfill()
        })
        wait(for: [expectationGeoOptions2], timeout: 10.0)
        XCTAssertNil(serversResult)
    }
}
