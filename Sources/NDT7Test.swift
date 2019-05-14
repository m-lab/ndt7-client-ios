//
//  NDT7Test.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/16/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// This protocol allows to receive the test information.
public protocol NDT7TestInteraction: class {

    /// Provide the status of download test
    /// - parameter running: true if the download test is running, otherwise, false.
    func downloadTestRunning(_ running: Bool)

    /// Provide the status of upload test
    /// - parameter running: true if the upload test is running, otherwise, false.
    func uploadTestRunning(_ running: Bool)

    /// Provide the measurement of download test
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    func downloadMeasurement(_ measurement: NDT7Measurement)

    /// Provide the measurement of upload test
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    func uploadMeasurement(_ measurement: NDT7Measurement)

    /// Error returned if something happen during a download test.
    /// - parameter error: Error during the download test.
    func downloadTestError(_ error: NSError)

    /// Error returned if something happen during an upload test.
    /// - parameter error: Error during the upload test.
    func uploadTestError(_ error: NSError)
}

/// This extension for NDT7TestInteraction protocol allows to have optional functions.
extension NDT7TestInteraction {

    /// Convert protocol downloadTestRunning function in optional
    /// - parameter running: true if the download test is running, otherwise, false.
    public func downloadTestRunning(_ running: Bool) {
        // Empty function for default implementation.
    }

    /// Convert protocol uploadTestRunning function in optional
    /// - parameter running: true if the upload test is running, otherwise, false.
    public func uploadTestRunning(_ running: Bool) {
        // Empty function for default implementation.
    }

    /// Convert protocol downloadMeasurement function in optional
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    public func downloadMeasurement(_ measurement: NDT7Measurement) {
        // Empty function for default implementation.
    }

    /// Convert protocol uploadMeasurement function in optional
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    public func uploadMeasurement(_ measurement: NDT7Measurement) {
        // Empty function for default implementation.
    }

    /// Convert protocol downloadTestError function in optional
    /// - parameter error: Error during the download test.
    public func downloadTestError(_ error: NSError) {
        // Empty function for default implementation.
    }

    /// Convert protocol uploadTestError function in optional
    /// - parameter error: Error during the upload test.
    public func uploadTestError(_ error: NSError) {
        // Empty function for default implementation.
    }
}

/// NDT7Test describes the version 7 of the Network Diagnostic Tool (NDT) protocol (ndt7).
/// It is a redesign of the original NDT network performance measurement protocol.
/// NDT7Test is based on WebSocket and TLS, and takes advantage of TCP BBR, where this flavour of TCP is available.
/// This is version v0.7.0 of the ndt7 specification.
/// For more information, please, visit the next link:
/// https://github.com/m-lab/ndt-server/blob/master/spec/ndt7-protocol.md
open class NDT7Test {

    /// ndt7TestInstances allows to run just one test. Not concurrency tests allowed.
    static var ndt7TestInstances = [WeakRef<NDT7Test>]()

    /// Download test running parameter. True if it is running, otherwise, false.
    var downloadTestRunning: Bool = false {
        didSet {
            if downloadTestRunning != oldValue {
                logNDT7("Download test running: \(downloadTestRunning)")
                delegate?.downloadTestRunning(downloadTestRunning)
            }
        }
    }

    /// Upload test running parameter. True if it is running, otherwise, false.
    var uploadTestRunning: Bool = false {
        didSet {
            if uploadTestRunning != oldValue {
                logNDT7("Upload test running: \(uploadTestRunning)")
                delegate?.uploadTestRunning(uploadTestRunning)
            }
        }
    }
    var webSocketDownload: WebSocketWrapper?
    var webSocketUpload: WebSocketWrapper?
    var downloadTestCompletion: ((_ error: NSError?) -> Void)?
    var uploadTestCompletion: ((_ error: NSError?) -> Void)?
    var timerDownload: Timer?
    var timerUpload: Timer?

    /// This delegate allows to return the test interaction information (`NDT7TestInteraction` protocol).
    public weak var delegate: NDT7TestInteraction?

    /// This parameter contains all the settings needed for ndt7 test.
    /// Please, check `NDT7Settings` for more information about the settings.
    public let settings: NDT7Settings

    /// Initialization.
    /// - parameter settings: Contains all the settings needed for ndt7 test (`NDT7Settings`).
    public init(settings: NDT7Settings) {
        self.settings = settings
        NDT7Test.ndt7TestInstances.append(WeakRef(self))
    }

    /// Deinit
    deinit {
        cancel()
        cleanup()
    }
}

/// This extension represent the public function to interact with NDT7Test.
extension NDT7Test {

    /// Start a test for download and/or upload, returning error if something was wrong.
    /// - parameter download: boolean to run download test.
    /// - parameter upload: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error if it happens during the tests.
    public func startTest(download: Bool, upload: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {

        logNDT7("NDT7 test started")

        // Cleanup and cancel any test in progress.
        cleanup()
        NDT7Test.ndt7TestInstances.forEach { $0.object?.cancel() }

        // Download test start.
        startDownload(download) { [weak self] (error) in
            self?.cleanup()
            self?.downloadTestRunning = false
            if let error = error {
                if error.localizedDescription == NDT7Constants.Test.cancelled {
                    logNDT7("NDT7 test cancelled")
                    completion(nil)
                    return
                }
                completion(error)
            }

            // Upload test start.
            self?.startUpload(upload) { (error) in
                self?.cleanup()
                self?.uploadTestRunning = false
                let testCancelled = error?.localizedDescription == NDT7Constants.Test.cancelled
                logNDT7("NDT7 test \(testCancelled ? "cancelled" : "finished")")
                completion(error == nil || testCancelled ? nil : error)
            }
        }
    }

    /// Cancel test running.
    public func cancel() {
        let error = NSError(domain: NDT7Constants.domain,
                            code: 0,
                            userInfo: [ NSLocalizedDescriptionKey: NDT7Constants.Test.cancelled])
        if downloadTestRunning {
            downloadTestCompletion?(error)
            downloadTestCompletion = nil
        }
        if uploadTestRunning {
            uploadTestCompletion?(error)
            uploadTestCompletion = nil
        }
        webSocketDownload?.delegate = nil
        webSocketUpload?.delegate = nil
        webSocketDownload?.close()
        webSocketUpload?.close()
        webSocketDownload = nil
        webSocketUpload = nil
        timerDownload?.invalidate()
        timerDownload = nil
        timerUpload?.invalidate()
        timerUpload = nil
    }
}

/// This extension represent the internal functions for NDT7Test.
extension NDT7Test {

    /// Start download test
    /// - parameter start: boolean to run download test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the download test.
    func startDownload(_ start: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start else {
            completion(nil)
            return
        }
        downloadTestCompletion = completion
        logNDT7("Download test setup")
        let url = settings.url.download
        if let downloadURL = URL(string: url) {
            timerDownload?.invalidate()
            timerDownload = Timer.scheduledTimer(withTimeInterval: settings.timeout.test,
                                                 repeats: false,
                                                 block: { [weak self] (_) in
                                                    self?.downloadTestCompletion?(nil)
                                                    self?.downloadTestCompletion = nil
            })
            RunLoop.main.add(timerDownload!, forMode: RunLoop.Mode.common)
            webSocketDownload = WebSocketWrapper(settings: settings, url: downloadURL)
            webSocketDownload?.delegate = self
        } else {
            logNDT7("Error with ndt7 download settings", .error)
        }
    }

    /// Start upload test
    /// - parameter start: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the upload test.
    func startUpload(_ start: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start else {
            completion(nil)
            return
        }
        uploadTestCompletion = completion
        logNDT7("Upload test setup")
        let url = settings.url.upload
        if let uploadURL = URL(string: url) {
            timerUpload?.invalidate()
            timerUpload = Timer.scheduledTimer(withTimeInterval: settings.timeout.test,
                                               repeats: false,
                                               block: { [weak self] (_) in
                                                self?.uploadTestCompletion?(nil)
                                                self?.uploadTestCompletion = nil
            })
            RunLoop.main.add(timerUpload!, forMode: RunLoop.Mode.common)
            webSocketUpload = WebSocketWrapper(settings: settings, url: uploadURL)
            webSocketUpload?.delegate = self
        } else {
            logNDT7("Error with ndt7 upload settings", .error)
        }
    }

    /// Uploader is a function to upload messages to the server to meassure the upload speed.
    /// - parameter socket: WebSocket object in charge of the upload.
    /// - parameter message: Data message to upload.
    /// - parameter t0: Initial date time.
    /// - parameter tlast: Last date time.
    /// - parameter count: Number of transmitted bytes.
    /// - parameter queue: Dispatch queue for upload.
    func uploader(socket: WebSocketWrapper, message: Data, t0: Date, tlast: Date, count: Int, queue: DispatchQueue) {

        var count = count
        var tlast = tlast
        var t1 = Date()
        let duration: TimeInterval = 10.0
        guard t1.timeIntervalSince1970 - t0.timeIntervalSince1970 < duration && uploadTestRunning == true else {
            uploadMessage(socket: socket, t0: t0, t1: t1, count: count)
            uploadTestCompletion?(nil)
            uploadTestCompletion = nil
            return
        }

        let underbuffered = 7 * message.count
        var buffered: Int? = 0
        let every: Double = 0.250
        while buffered != nil && buffered! < underbuffered && t1.timeIntervalSince1970 - t0.timeIntervalSince1970 < duration && uploadTestRunning == true {
            buffered = socket.send(message, maxBuffer: underbuffered)
            if buffered != nil {
                count += message.count
                t1 = Date()
                if t1.timeIntervalSince1970 - tlast.timeIntervalSince1970 > every {
                    tlast = t1
                    uploadMessage(socket: socket, t0: t0, t1: t1, count: count)
                }
            }
        }
        queue.asyncAfter(deadline: .now()) { [weak self] in
            self?.uploader(socket: socket, message: message, t0: t0, tlast: tlast, count: count, queue: queue)
        }
    }

    /// Upload message upload a NDT7Measurement object to the delegate
    /// with the current elapsed time and number of transmitted bytes.
    /// - parameter t0: Initial date time.
    /// - parameter t1: Current date time.
    /// - parameter count: Number of transmitted bytes.
    func uploadMessage(socket: WebSocketWrapper, t0: Date, t1: Date, count: Int) {
        guard socket === webSocketUpload else { return }
        let message = "{\"elapsed\": \(t1.timeIntervalSince1970 - t0.timeIntervalSince1970), \"app_info\": { \"num_bytes\": \(count)}}"
        if let measurement = handleMessage(message) {
            logNDT7("Upload test \(measurement)")
            delegate?.uploadMeasurement(measurement)
        }
    }

    /// Handle message returned from server to convert in a NDT7Measurement object.
    /// - parameter message: object returned from server.
    /// - returns: NDT7Measurement with a json text translated to measurement data.
    func handleMessage(_ message: Any) -> NDT7Measurement? {
        if let message = message as? String, let data = message.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode(NDT7Measurement.self, from: data)
                return decoded
            } catch {
                logNDT7("Failed to decode message", .error)
            }
        }
        return nil
    }

    /// Cleanup
    func cleanup() {
        webSocketDownload?.delegate = nil
        webSocketUpload?.delegate = nil
        webSocketDownload = nil
        webSocketUpload = nil
        downloadTestCompletion = nil
        uploadTestCompletion = nil
        timerDownload?.invalidate()
        timerUpload?.invalidate()
        timerDownload = nil
        timerUpload = nil
    }
}

/// This extension provide the web socket interaction.
/// It's used to return data via delegation through delegate object (NDT7TestInteraction).
extension NDT7Test: WebSocketInteraction {

    func open(webSocket: WebSocketWrapper) {
        if webSocket === webSocketDownload {
            downloadTestRunning = true
        } else if webSocket === webSocketUpload {
            uploadTestRunning = true
            let dataArray: [UInt8] = (0..<(1 << 13)).map { _ in
                UInt8.random(in: 1...255)
            }
            let data = dataArray.withUnsafeBufferPointer { Data(buffer: $0) }
//            let dispatchQueue = DispatchQueue.init(label: "net.measurementlab.NDT7.upload.test")
            let dispatchQueue = DispatchQueue.init(label: "net.measurementlab.NDT7.upload.test", qos: .userInitiated)
            dispatchQueue.async { [weak self] in
                self?.uploader(socket: webSocket, message: data, t0: Date(), tlast: Date(), count: 0, queue: dispatchQueue)
            }
            dispatchQueue.async { [weak self] in
                self?.uploader(socket: webSocket, message: data, t0: Date(), tlast: Date(), count: 0, queue: dispatchQueue)
            }
        }
    }

    func close(webSocket: WebSocketWrapper) {
        if webSocket === webSocketDownload {
            downloadTestCompletion?(nil)
            downloadTestCompletion = nil
            timerDownload?.invalidate()
            timerDownload = nil
        } else if webSocket === webSocketUpload {
            uploadTestCompletion?(nil)
            uploadTestCompletion = nil
            timerUpload?.invalidate()
            timerUpload = nil
        }
    }

    func message(webSocket: WebSocketWrapper, message: Any) {
        guard var measurement = handleMessage(message) else { return }
        if webSocket === webSocketDownload {
            let appInfo = NDT7APPInfo(numBytes: Int64(webSocket.inputBytesLengthAccumulated))
            measurement.appInfo = appInfo
            logNDT7("Download test \(measurement)")
            delegate?.downloadMeasurement(measurement)
        }
    }

    func error(webSocket: WebSocketWrapper, error: NSError) {
        if webSocket === webSocketDownload {
            logNDT7("Download test error: \(error.localizedDescription)", .error)
            delegate?.downloadTestError(error)
            downloadTestCompletion?(error)
            downloadTestCompletion = nil
        } else if webSocket === webSocketUpload {
            logNDT7("Upload test error: \(error.localizedDescription)", .error)
            delegate?.uploadTestError(error)
            uploadTestCompletion?(error)
            uploadTestCompletion = nil
        }
    }
}
