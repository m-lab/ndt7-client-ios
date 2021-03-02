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

    func testDiscoverServerSucceeds() {

        // The server is discovered without geo options enabled (NDT7 server cache disabled).
        let session = URLSessionMock()
        let jsonServerData = """
        {
            "results": [
                {
                    "machine": "mlab2-lga05.measurement-lab.org",
                    "location": {
                            "city": "San Francisco",
                            "country": "US"
                    },
                    "urls": {
                        "wss:///ndt/v7/download": "wss://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/download?access_token=.",
                        "wss:///ndt/v7/upload": "wss://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/upload?access_token=.",
                        "ws:///ndt/v7/download": "ws://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/download?access_token=.",
                        "ws:///ndt/v7/upload": "ws://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/upload?access_token=.",
                    }
                }
            ]
        }
        """.data(using: .utf8)
        session.data = jsonServerData
        var result = false
        var serversResult: [NDT7Server]?
        var resultingError: NSError?
        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                retry: 100, { (servers, error) in
                                    serversResult = servers
                                    resultingError = error
                                    result = true
                                    expectation.fulfill()
                                })
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(result)
        XCTAssertNotNil(serversResult)
        XCTAssertNil(resultingError)

        XCTAssertEqual(serversResult?.count, 1)
        let server = serversResult?.first
        XCTAssertEqual(server?.machine, "mlab2-lga05.measurement-lab.org")
        XCTAssertEqual(server?.location?.city, "San Francisco")
        XCTAssertEqual(server?.location?.country, "US")
        XCTAssertEqual(server?.urls.downloadPath, "wss://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/download?access_token=.")
        XCTAssertEqual(server?.urls.uploadPath, "wss://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/upload?access_token=.")
        XCTAssertEqual(server?.urls.insecureDownloadPath, "ws://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/download?access_token=.")
        XCTAssertEqual(server?.urls.insecureUploadPath, "ws://ndt-mlab2-lga05.measurement-lab.org/ndt/v7/upload?access_token=.")
    }

    func testDiscoverServerFailsWithError() {
        // If there is an error getting a new server, the server can't be discovered.
        let session = URLSessionMock()
        let jsonServerData = """
        {
            "results": [
                {
                    "machine": "mlab2-lga05.measurement-lab.org",
                    "location": {
                            "city": "San Francisco",
                            "country": "US"
                    }
                }
            ]
        }
        """.data(using: .utf8)
        session.data = jsonServerData

        var serversResult: [NDT7Server]?
        var resultingError: NSError?

        let expectation = XCTestExpectation(description: "Job in main thread")
        _ = NDT7Server.discover(session: session,
                                retry: 100, { (server, error) in
                                    serversResult = server
                                    resultingError = error
                                    expectation.fulfill()
                                })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(serversResult)
        XCTAssertNotNil(resultingError)
        XCTAssertEqual(resultingError, NDT7WebSocketConstants.MlabServerDiscover.noMlabServerError)
    }
}
