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

let jsonServerData = """
{
  "results": [
    {
      "machine": "mlab1-atl02.mlab-oti.measurement-lab.org",
      "location": {
        "city": "Atlanta",
        "country": "US"
      },
      "urls": {
        "ws:///ndt/v7/download": "ws://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ",
        "ws:///ndt/v7/upload": "ws://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ",
        "wss:///ndt/v7/download": "wss://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ",
        "wss:///ndt/v7/upload": "wss://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ"
      }
    },
    {
      "machine": "mlab1-atl03.mlab-oti.measurement-lab.org",
      "location": {
        "city": "Atlanta",
        "country": "US"
      },
      "urls": {
        "ws:///ndt/v7/download": "ws://ndt-mlab1-atl03.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDMubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAzLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.zgCcTD5FsdAMjEFGqAHB1tiQpEcS7zbMIXwBEUmIfOFiZN4r3lwfUSrTMm4QbKsrhCBjb7ztkAvOr87yuzs9Bw",
        "ws:///ndt/v7/upload": "ws://ndt-mlab1-atl03.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDMubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAzLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.zgCcTD5FsdAMjEFGqAHB1tiQpEcS7zbMIXwBEUmIfOFiZN4r3lwfUSrTMm4QbKsrhCBjb7ztkAvOr87yuzs9Bw",
        "wss:///ndt/v7/download": "wss://ndt-mlab1-atl03.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDMubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAzLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.zgCcTD5FsdAMjEFGqAHB1tiQpEcS7zbMIXwBEUmIfOFiZN4r3lwfUSrTMm4QbKsrhCBjb7ztkAvOr87yuzs9Bw",
        "wss:///ndt/v7/upload": "wss://ndt-mlab1-atl03.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDMubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAzLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.zgCcTD5FsdAMjEFGqAHB1tiQpEcS7zbMIXwBEUmIfOFiZN4r3lwfUSrTMm4QbKsrhCBjb7ztkAvOr87yuzs9Bw"
      }
    },
    {
      "machine": "mlab3-atl08.mlab-oti.measurement-lab.org",
      "location": {
        "city": "Atlanta",
        "country": "US"
      },
      "urls": {
        "ws:///ndt/v7/download": "ws://ndt-mlab3-atl08.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjMtYXRsMDgubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIzLmF0bDA4Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.EBdE0ub_VIxxXn_3Pk8kqG31e3iIDaR0fniPrTXFEdnKpTeepUTOIr0QbovfspMnuRBtVqD0YPBXidPR0mesAA",
        "ws:///ndt/v7/upload": "ws://ndt-mlab3-atl08.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjMtYXRsMDgubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIzLmF0bDA4Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.EBdE0ub_VIxxXn_3Pk8kqG31e3iIDaR0fniPrTXFEdnKpTeepUTOIr0QbovfspMnuRBtVqD0YPBXidPR0mesAA",
        "wss:///ndt/v7/download": "wss://ndt-mlab3-atl08.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjMtYXRsMDgubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIzLmF0bDA4Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.EBdE0ub_VIxxXn_3Pk8kqG31e3iIDaR0fniPrTXFEdnKpTeepUTOIr0QbovfspMnuRBtVqD0YPBXidPR0mesAA",
        "wss:///ndt/v7/upload": "wss://ndt-mlab3-atl08.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjMtYXRsMDgubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIzLmF0bDA4Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.EBdE0ub_VIxxXn_3Pk8kqG31e3iIDaR0fniPrTXFEdnKpTeepUTOIr0QbovfspMnuRBtVqD0YPBXidPR0mesAA"
      }
    },
    {
      "machine": "mlab1-atl04.mlab-oti.measurement-lab.org",
      "location": {
        "city": "Atlanta",
        "country": "US"
      },
      "urls": {
        "ws:///ndt/v7/download": "ws://ndt-mlab1-atl04.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDQubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDA0Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.q3IgAwb5Y57QIQ3mEgfdU39RSTvEB08GDJfdMdcI5kjn6SdLkhIWBggu4I_l48W3vmXuRoCT14c7bCrqVBRgDQ",
        "ws:///ndt/v7/upload": "ws://ndt-mlab1-atl04.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDQubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDA0Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.q3IgAwb5Y57QIQ3mEgfdU39RSTvEB08GDJfdMdcI5kjn6SdLkhIWBggu4I_l48W3vmXuRoCT14c7bCrqVBRgDQ",
        "wss:///ndt/v7/download": "wss://ndt-mlab1-atl04.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDQubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDA0Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.q3IgAwb5Y57QIQ3mEgfdU39RSTvEB08GDJfdMdcI5kjn6SdLkhIWBggu4I_l48W3vmXuRoCT14c7bCrqVBRgDQ",
        "wss:///ndt/v7/upload": "wss://ndt-mlab1-atl04.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDQubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDA0Lm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.q3IgAwb5Y57QIQ3mEgfdU39RSTvEB08GDJfdMdcI5kjn6SdLkhIWBggu4I_l48W3vmXuRoCT14c7bCrqVBRgDQ"
      }
    }
  ]
}
""".data(using: .utf8)

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
    
    /// Validates that we read the correct URLs to run the tests against from the Locate API V2
    func testDiscoverServerV2() {
        // Prepare mock data
        let session = URLSessionMock()
        session.data = jsonServerData
        var result = false
        var serverResult: [NDT7ServerV2]?
        let expectation = XCTestExpectation(description: "Job in main thread")
        
        // Call discovery
        _ = NDT7ServerV2.discoverV2(session: session, { (server, _) in
            serverResult = server
            result = true
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertNotNil(serverResult)
        XCTAssertEqual(serverResult?[0].urls.uploadUrl, "wss://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ")
        XCTAssertEqual(serverResult?[0].urls.downloadUrl, "wss://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ")
        XCTAssertEqual(serverResult?[0].urls.insecureUploadUrl, "ws://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/upload?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ")
        XCTAssertEqual(serverResult?[0].urls.insecureDownloadUrl, "ws://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ")
    }

    func testDecodeServer() throws {
        let apiResponse = try? JSONDecoder().decode(LocateAPIV2Response.self, from: jsonServerData!)
        let maybeServer = apiResponse?.results[0]
        guard let server = maybeServer else { XCTFail(); return}
        
        // Assert the contents of the server
        XCTAssertEqual(server.machine, "mlab1-atl02.mlab-oti.measurement-lab.org")
        XCTAssertEqual(server.location.city, "Atlanta")
        XCTAssertEqual(server.location.country, "US")
        XCTAssertEqual(server.urls.downloadUrl, "wss://ndt-mlab1-atl02.mlab-oti.measurement-lab.org/ndt/v7/download?access_token=eyJhbGciOiJFZERTQSIsImtpZCI6ImxvY2F0ZV8yMDIwMDQwOSJ9.eyJhdWQiOlsibWxhYjEtYXRsMDIubWxhYi1vdGkubWVhc3VyZW1lbnQtbGFiLm9yZyIsIm1sYWIxLmF0bDAyLm1lYXN1cmVtZW50LWxhYi5vcmciXSwiZXhwIjoxNjAzOTIxODE1LCJpc3MiOiJsb2NhdGUiLCJzdWIiOiJuZHQifQ.22owCDnIB0aM8Kd3NZ7GmtA-WcLz_0hvrkMbumq-B4QAM1ZBlFqGp7zHGLzainLjEhbqb4JHV56v56CYNayyAQ")
    }
}
