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

    func testNdt7TestInstances() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let instances = NDT7Test.ndt7TestInstances
        XCTAssertTrue(!instances.isEmpty)
        XCTAssertTrue(instances.contains(where: { $0.object === ndt7Test }))
    }

    func testNdt7TestStartTest() {

        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: ""))
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
        ndt7Test?.startTest(download: false, upload: false, { (error) in
            XCTAssertNil(error)
        })
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
        ndt7Test?.startTest(download: true, upload: true, { (error) in
            XCTAssertNotNil(error)
        })
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNotNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)

        ndt7Test?.timerDownload?.invalidate()
        ndt7Test?.timerUpload?.invalidate()
        ndt7Test?.timerDownload = nil
        ndt7Test?.timerUpload = nil
        ndt7Test?.downloadTestCompletion = downloadCompletion
        ndt7Test?.uploadTestCompletion = uploadCompletion
        XCTAssertNotNil(ndt7Test?.downloadTestCompletion)
        XCTAssertNotNil(ndt7Test?.uploadTestCompletion)
        XCTAssertNil(ndt7Test?.timerDownload)
        XCTAssertNil(ndt7Test?.timerUpload)
        XCTAssertFalse(startDownloadCheck)
        XCTAssertFalse(startUploadCheck)
        ndt7Test?.startTest(download: false, upload: true, { (error) in
            XCTAssertNil(error)
        })
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

    func testNDT7TestHhandleMessage() {
        let measurementJSON = """
{
"elapsed": 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        let message = ndt7Test?.handleMessage(measurementJSON)
        XCTAssertNotNil(message)
        XCTAssertEqual(message?.elapsed, 1)
        XCTAssertEqual(message?.tcpInfo?.smoothedRtt, 2)
        XCTAssertEqual(message?.tcpInfo?.rttVar, 3)
        XCTAssertEqual(message?.appInfo?.numBytes, 4)
        XCTAssertEqual(message?.bbrInfo?.bandwith, 5)
        XCTAssertEqual(message?.bbrInfo?.minRtt, 6)
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
        ndt7Test?.startDownload(false, { (error) in
            XCTAssertNil(error)
        })
    }

    func testNDT7TestStartDownloadTrue() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: "$5^7~c` "))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startDownloadCheck = false
        let completion: (_ error: NSError?) -> Void = { (error) in
            startDownloadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test?.startDownload(true, completion)
        XCTAssertFalse(startDownloadCheck)
        ndt7Test?.downloadTestCompletion?(nil)
        XCTAssertTrue(startDownloadCheck)
    }

    func testNDT7TestStartUploadFalse() {
        let ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        ndt7Test?.startUpload(false, { (error) in
            XCTAssertNil(error)
        })
    }

    func testNDT7TestStartUploadTrue() {
        let settings = NDT7Settings(url: NDT7URL(hostname: "", downloadPath: ""))
        let ndt7Test: NDT7Test? = NDT7Test(settings: settings)
        var startUploadCheck = false
        let completion: (_ error: NSError?) -> Void = { (error) in
            startUploadCheck = true
            XCTAssertNil(error)
        }
        ndt7Test?.startUpload(true, completion)
        XCTAssertTrue(startUploadCheck)
        ndt7Test?.downloadTestCompletion?(nil)
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
        XCTAssertEqual(settings.url.hostname, "35.235.104.27")
        XCTAssertEqual(settings.url.downloadPath, "/ndt/v7/download")
        XCTAssertEqual(settings.url.uploadPath, "/ndt/v7/upload")
        XCTAssertTrue(settings.url.wss)
        XCTAssertTrue(settings.skipTLSCertificateVerification)
        XCTAssertEqual(settings.timeout.measurement, 5.5)
        XCTAssertEqual(settings.timeout.request, 5)
        XCTAssertEqual(settings.timeout.test, 15)
        XCTAssertEqual(settings.headers["Sec-WebSocket-Protocol"], "net.measurementlab.ndt.v7")
        XCTAssertEqual(settings.headers["Sec-WebSocket-Accept"], "Nhz+x95YebD6Uvd4nqPC2fomoUQ=")
        XCTAssertEqual(settings.headers["Sec-WebSocket-Version"], "13")
        XCTAssertEqual(settings.headers["Sec-WebSocket-Key"], "DOdm+5/Cm3WwvhfcAlhJoQ==")
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

        XCTAssertTrue(ndt7Test.downloadMeasurement.isEmpty)
        XCTAssertTrue(ndt7Test.uploadMeasurement.isEmpty)
        ndt7Test.message(webSocket: webSocketDownload, message: "..")
        ndt7Test.message(webSocket: webSocketUpload, message: "..")
        XCTAssertTrue(ndt7Test.downloadMeasurement.isEmpty)
        XCTAssertTrue(ndt7Test.uploadMeasurement.isEmpty)

        let measurementJSON = """
{
"elapsed": 1,
"tcp_info": { "smoothed_rtt": 2, "rtt_var": 3 },
"app_info": { "num_bytes": 4 },
"bbr_info": { "max_bandwidth" : 5, "min_rtt": 6 }
}
"""
        XCTAssertTrue(ndt7Test.downloadMeasurement.isEmpty)
        XCTAssertTrue(ndt7Test.uploadMeasurement.isEmpty)
        ndt7Test.message(webSocket: webSocketDownload, message: measurementJSON)
        ndt7Test.message(webSocket: webSocketUpload, message: measurementJSON)
        XCTAssertTrue(!ndt7Test.downloadMeasurement.isEmpty)
        XCTAssertTrue(!ndt7Test.uploadMeasurement.isEmpty)

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
