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

    class TestInteractionMock: NDT7TestInteraction {
        var count: Int? = 0
        var elapsed: Int64? = 0
        var direction: NDT7TestConstants.Kind?
        var origin: NDT7TestConstants.Origin?
        var rawData: String?
        var measurement: NDT7Measurement?
        func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
            self.measurement = measurement
            elapsed = self.measurement?.appInfo?.elapsedTime
            self.direction = measurement.direction
            self.origin = measurement.origin
            self.rawData = measurement.rawData
            if let count = measurement.appInfo?.numBytes {
                self.count = Int(count)
            }
        }
    }

    func testNdt7TestInstances() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let instances = NDT7Test.ndt7TestInstances
        XCTAssertTrue(!instances.isEmpty)
        XCTAssertTrue(instances.contains(where: { $0.object === ndt7Test }))
    }

    func testNdt7TestStartTestFalse() {

        let settings = NDT7Settings(url: NDT7URL(hostname: "hostname.com", downloadPath: ""))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startDownloadCheck = false
        let downloadCompletion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNil(error)
        }
        var startUploadCheck = false
        let uploadCompletion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion

        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        let expectationFalseFalse = XCTestExpectation(description: "Job in main thread")
        var check = false
        ndt7Test?.startTest(download: false, upload: false, { (error) in
            XCTAssertNil(error)
            check = true
            expectationFalseFalse.fulfill()
        })
        wait(for: [expectationFalseFalse], timeout: 5.0)
        XCTAssertTrue(check)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
    }

    func testNdt7TestStartTestTrue() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "hostname.com", downloadPath: ""))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startDownloadCheck = false
        let downloadCompletion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNil(error)
        }
        var startUploadCheck = false
        let uploadCompletion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNil(error)
        }

        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        var check = false
        ndt7Test?.startTest(download: true, upload: true, { (error) in
            XCTAssertNil(error)
            check = true
        })
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        ndt7Test?.downloadTestCompletion?(nil)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        ndt7Test?.uploadTestCompletion?(nil)
        XCTAssertTrue(check)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)

        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        check = false
        ndt7Test?.startTest(download: false, upload: true, { (error) in
            XCTAssertNil(error)
            check = true
        })
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertFalse(check)
        ndt7Test?.downloadTestCompletion?(nil)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertFalse(check)
        ndt7Test?.uploadTestCompletion?(nil)
        XCTAssertTrue(check)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)

        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        check = false
        ndt7Test?.startTest(download: true, upload: false, { (error) in
            XCTAssertNil(error)
            check = true
        })
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertFalse(check)
        ndt7Test?.downloadTestCompletion?(nil)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertTrue(check)
        ndt7Test?.uploadTestCompletion?(nil)
        XCTAssertTrue(check)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
    }

    func testNDT7TestCleanup() {

        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: ""))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        let downloadCompletion: (_ error: NSError?) -> Void = { (error) in
            XCTAssertNil(error)
        }
        let uploadCompletion: (_ error: NSError?) -> Void = { (error) in
            XCTAssertNil(error)
        }
        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        ndt7Test?.timerDownload = Timer(timeInterval: 1, repeats: false, block: { (_) in })
        ndt7Test?.timerUpload = Timer(timeInterval: 1, repeats: false, block: { (_) in })

        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.timerDownload)
        XCTAssertNotNil(ndt7Test?.timerUpload)
        ndt7Test?.cleanup()
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
    }

    func testServerSetup() {

        var settings = NDT7Settings(url: NDT7URL(hostname: "hostname.com"))
        var ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var result = false
        var expectation = XCTestExpectation(description: "Job in main thread")
        ndt7Test?.serverSetup({ (error) in
            result = true
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)

        settings = NDT7Settings(url: NDT7URL(hostname: ""))
        ndt7Test = NDT7Test(settings: settings)
        result = false
        expectation = XCTestExpectation(description: "Job in main thread")
        ndt7Test?.serverSetup({ (_) in
            result = true
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(result)
    }

    func testNDT7TestUploader() {

        let dataArray: [UInt8] = (0..<(1 << 13)).map { _ in
            UInt8.random(in: 1...255)
        }
        let data = dataArray.withUnsafeBufferPointer { Data(buffer: $0) }
        let dispatchQueue = DispatchQueue.init(label: "net.measurementlab.NDT7.upload.test", attributes: .concurrent)
        let t0 = Date().addingTimeInterval(-10000000)
        let tlast = Date().addingTimeInterval(10000000)
        let count = 123456
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: "", uploadPath: ""))
        let url = URL.init(string: "127.0.0.1")
        let webSocketUpload = WebSocketWrapper(settings: settings, url: url!)!

        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test!.webSocketUpload = webSocketUpload
        let testInteractionMock = TestInteractionMock()
        ndt7Test?.delegate = testInteractionMock

        ndt7Test?.uploader(socket: webSocketUpload, message: data, t0: t0, tlast: tlast, count: count, queue: dispatchQueue)
        XCTAssertNotNil(testInteractionMock.elapsed)
        XCTAssertEqual(testInteractionMock.count, count)
    }

    func testNDT7TestUploadMessage() {
        let t0 = Date()
        let t1 = Date()
        let count = 123456
        let settings = NDT7Settings()
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        let testInteractionMock = TestInteractionMock()
        ndt7Test?.delegate = testInteractionMock
        ndt7Test?.webSocketUpload = WebSocketWrapper(settings: settings, url: URL(string: settings.url.uploadPath)!)
        ndt7Test?.uploadMessage(socket: ndt7Test!.webSocketUpload!, t0: t0, t1: t1, count: count)
        XCTAssertEqual(testInteractionMock.count, count)
        XCTAssertEqual(testInteractionMock.direction, .upload)
        XCTAssertEqual(testInteractionMock.origin, .client)
//        XCTAssertEqual(testInteractionMock.rawData, "{\"rawData\":\"{ }\",\"AppInfo\":{\"ElapsedTime\":0,\"NumBytes\":123456},\"Origin\":\"client\",\"Test\":\"upload\"}")
//        XCTAssertEqual(testInteractionMock.elapsed, Int64(t1.timeIntervalSince1970 - t0.timeIntervalSince1970))
    }

    func testNDT7TestHhandleMessage() {
        let measurementJSON = """
{
 "AppInfo": {
   "ElapsedTime": 12341,
   "NumBytes": 12342,
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
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let message = ndt7Test?.handleMessage(measurementJSON)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.appInfo?.elapsedTime, 12341)
        XCTAssertEqual(message?.appInfo?.numBytes, 12342)
        XCTAssertEqual(message?.connectionInfo?.client, "1.2.3.4:5678")
        XCTAssertEqual(message?.connectionInfo?.server, "[::1]:2345")
        XCTAssertEqual(message?.connectionInfo?.uuid, "<platform-specific-string>")
        XCTAssertEqual(message?.connectionInfo?.uuid, "<platform-specific-string>")
        XCTAssertEqual(message?.origin, .server)
        XCTAssertEqual(message?.direction, .download)
        XCTAssertEqual(message?.tcpInfo?.busyTime, 1234)
        XCTAssertEqual(message?.tcpInfo?.bytesAcked, 12345)
        XCTAssertEqual(message?.tcpInfo?.bytesReceived, 12346)
        XCTAssertEqual(message?.tcpInfo?.bytesSent, 12347)
        XCTAssertEqual(message?.tcpInfo?.bytesRetrans, 12348)
        XCTAssertEqual(message?.tcpInfo?.elapsedTime, 12349)
        XCTAssertEqual(message?.tcpInfo?.minRTT, 12340)
        XCTAssertEqual(message?.tcpInfo?.rtt, 123411)
        XCTAssertEqual(message?.tcpInfo?.rttVar, 123412)
        XCTAssertEqual(message?.tcpInfo?.rwndLimited, 123413)
        XCTAssertEqual(message?.tcpInfo?.sndBufLimited, 123414)
        XCTAssertEqual(message?.rawData, measurementJSON)
    }

    func testNDT7TestHhandleWrongMessage() {
        let measurementJSON = """
{
elapsed: 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let message = ndt7Test?.handleMessage(measurementJSON)
        XCTAssertNil(message)
    }

    func testNDT7TestStartDownloadFalse() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.startDownload(false, error: nil, { (error) in
            XCTAssertNil(error)
        })

        var startDownloadCheck = false
        let completionWithError: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNotNil(error)
        }
        ndt7Test?.startDownload(false, error: NDT7TestConstants.cancelledError, completionWithError)
        XCTAssertTrue(startDownloadCheck)
    }

    func testNDT7TestStartDownloadTrue() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: "$5^7~c` "))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startDownloadCheck = false
        let completion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test?.startDownload(true, error: nil, completion)
        XCTAssertFalse(startDownloadCheck)
        ndt7Test?.downloadTestCompletion?(nil)
        XCTAssertTrue(startDownloadCheck)

        startDownloadCheck = false
        let completionWithError: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNotNil(error)
        }
        ndt7Test?.startDownload(true, error: NDT7TestConstants.cancelledError, completionWithError)
        XCTAssertTrue(startDownloadCheck)
    }

    func testNDT7TestStartUploadFalse() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.startUpload(false, error: nil, { (error) in
            XCTAssertNil(error)
        })

        var startUploadCheck = false
        let completionWithError: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNotNil(error)
        }
        ndt7Test?.startUpload(false, error: NDT7TestConstants.cancelledError, completionWithError)
        XCTAssertTrue(startUploadCheck)
    }

    func testNDT7TestStartUploadTrue() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: "$5^7~c` "))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startUploadCheck = false
        let completion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test?.startUpload(true, error: nil, completion)
        XCTAssertFalse(startUploadCheck)
        ndt7Test?.uploadTestCompletion?(nil)
        XCTAssertTrue(startUploadCheck)

        startUploadCheck = false
        let completionWithError: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNotNil(error)
        }
        ndt7Test?.startUpload(true, error: NDT7TestConstants.cancelledError, completionWithError)
        XCTAssertTrue(startUploadCheck)
    }

    func testNDT7TestCancel() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        var downloadCompletionCheck = false
        let downloadCompletion: ((_ error: NSError?) -> Void)? = { (error) in
            downloadCompletionCheck = true
        }
        var uploadCompletionCheck = false
        let uploadCompletion: ((_ error: NSError?) -> Void)? = { (error) in
            uploadCompletionCheck = true
        }
        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        ndt7Test?.timerDownload = Timer(timeInterval: 3, repeats: false, block: { (_) in })
        ndt7Test?.timerUpload = Timer(timeInterval: 3, repeats: false, block: { (_) in })
        ndt7Test?.downloadTestRunning = true
        ndt7Test?.uploadTestRunning = true
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertFalse(downloadCompletionCheck)
        XCTAssertFalse(uploadCompletionCheck)
        XCTAssertNotNil(ndt7Test?.timerDownload)
        XCTAssertNotNil(ndt7Test?.timerUpload)
        XCTAssertTrue(ndt7Test!.downloadTestRunning)
        XCTAssertTrue(ndt7Test!.uploadTestRunning)
        ndt7Test?.cancel()
        XCTAssertNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertNil(ndt7Test?.webSocketDownload)
        XCTAssertNil(ndt7Test?.webSocketUpload)
        XCTAssertTrue(downloadCompletionCheck)
        XCTAssertTrue(uploadCompletionCheck)
    }

    func testNDT7SettingsMeasurementInterval() {
        let settings = NDT7Settings(timeout: NDT7Timeouts(measurement: 5.5))
        XCTAssertEqual(settings.url.hostname, "")
        XCTAssertEqual(settings.url.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(settings.url.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(settings.url.wss)
        XCTAssertTrue(settings.skipTLSCertificateVerification)
        XCTAssertEqual(settings.timeout.measurement, 5.5)
        XCTAssertEqual(settings.timeout.ioTimeout, 7)
        XCTAssertEqual(settings.timeout.downloadTimeout, 15)
        XCTAssertEqual(settings.timeout.uploadTimeout, 15)
        XCTAssertEqual(settings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
    }

    func testWebSocketInteraction() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: "", uploadPath: ""))
        let url = URL.init(string: "127.0.0.1")
        let webSocketDownload = WebSocketWrapper(settings: settings, url: url!)!
        let webSocketUpload = WebSocketWrapper(settings: settings, url: url!)!
        let ndt7Test = NDT7Test(settings: settings)
        var startDownloadCheck = false
        var startUploadCheck = false
        let downloadCompletion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNil(error)
        }
        let uploadCompletion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test.downloadTestCompletion = downloadCompletion
        ndt7Test.uploadTestCompletion = uploadCompletion
        ndt7Test.webSocketDownload = webSocketDownload
        ndt7Test.webSocketUpload = webSocketUpload

        XCTAssertFalse(ndt7Test.downloadTestRunning)
        XCTAssertFalse(ndt7Test.uploadTestRunning)
        ndt7Test.open(webSocket: webSocketDownload)
        ndt7Test.open(webSocket: webSocketUpload)
        XCTAssertTrue(ndt7Test.downloadTestRunning)
        XCTAssertTrue(ndt7Test.uploadTestRunning)

        ndt7Test.timerDownload = Timer.init(timeInterval: 1, repeats: false, block: { (_) in })
        ndt7Test.timerUpload = Timer.init(timeInterval: 1, repeats: false, block: { (_) in })
        XCTAssertNotNil(ndt7Test.timerDownload)
        XCTAssertNotNil(ndt7Test.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        ndt7Test.close(webSocket: webSocketDownload)
        ndt7Test.close(webSocket: webSocketUpload)
        XCTAssertNil(ndt7Test.timerDownload)
        XCTAssertNil(ndt7Test.timerUpload)
        XCTAssertTrue(startDownloadCheck)
        XCTAssertTrue(startUploadCheck)

        ndt7Test.message(webSocket: webSocketDownload, message: "..")
        ndt7Test.message(webSocket: webSocketUpload, message: "..")

        let measurementJSON = """
{
"elapsed": 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        ndt7Test.message(webSocket: webSocketDownload, message: measurementJSON)
        ndt7Test.message(webSocket: webSocketUpload, message: measurementJSON)

        let error = NSError(domain: "net.measurementlab.NDT7",
                            code: 0,
                            userInfo: [ NSLocalizedDescriptionKey: "Test cancelled"])
        let downloadErrorCompletion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNotNil(error)
        }
        let uploadErrorCompletion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNotNil(error)
        }
        startDownloadCheck = false
        startUploadCheck = false
        ndt7Test.downloadTestCompletion = downloadErrorCompletion
        ndt7Test.uploadTestCompletion = uploadErrorCompletion
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        ndt7Test.error(webSocket: webSocketDownload, error: error)
        ndt7Test.error(webSocket: webSocketUpload, error: error)
        XCTAssertNil(ndt7Test.downloadTestCompletion)
        XCTAssertNil(ndt7Test.uploadTestCompletion)
        XCTAssertTrue(startDownloadCheck)
        XCTAssertTrue(startUploadCheck)
    }
}
