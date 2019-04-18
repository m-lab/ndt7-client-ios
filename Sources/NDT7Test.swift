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
    func downloadTestRunning(_ running: Bool)
    func uploadTestRunning(_ running: Bool)
    func downloadMeasurement(_ measurement: NDT7Measurement)
    func uploadMeasurement(_ measurement: NDT7Measurement)
    func downloadTestError(_ error: NSError)
    func uploadTestError(_ error: NSError)
}

/// This extension for NDT7TestInteraction protocol allows to have optional functions.
extension NDT7TestInteraction {
    func downloadTestRunning(_ running: Bool) { }
    func uploadTestRunning(_ running: Bool) { }
    func downloadMeasurement(_ measurement: NDT7Measurement) { }
    func uploadMeasurement(_ measurement: NDT7Measurement) { }
    func downloadTestError(_ error: NSError) { }
    func uploadTestError(_ error: NSError) { }
}

/// NDT7Test describes the version 7 of the Network Diagnostic Tool (NDT) protocol (ndt7).
/// It is a redesign of the original NDT network performance measurement protocol.
/// NDT7Test is based on WebSocket and TLS, and takes advantage of TCP BBR, where this flavour of TCP is available.
/// This is version v0.7.0 of the ndt7 specification.
/// https://github.com/m-lab/ndt-server/blob/master/spec/ndt7-protocol.md
open class NDT7Test {

    /// ndt7TestInstances allows to run just one test, not concurrency allowed.
    private static var ndt7TestInstances = [WeakRef<NDT7Test>]()

    /// Download test running parameter. True if it is running, otherwise false.
    private var downloadTestRunning: Bool = false {
        didSet {
            logNDT7("Download test running: \(downloadTestRunning)")
            delegate?.downloadTestRunning(downloadTestRunning)
        }
    }

    /// Upload test running parameter. True if it is running, otherwise false.
    private var uploadTestRunning: Bool = false {
        didSet {
            logNDT7("Upload test running: \(uploadTestRunning)")
            delegate?.uploadTestRunning(uploadTestRunning)
        }
    }
    private var webSocketDownload: WebSocketWrapper?
    private var webSocketUpload: WebSocketWrapper?
    private var downloadTestCompletion: ((_ error: NSError?) -> Void)?
    private var uploadTestCompletion: ((_ error: NSError?) -> Void)?
    private var downloadMeasurement: [NDT7Measurement] = []
    private var uploadMeasurement: [NDT7Measurement] = []
    private var timerDownload: Timer?
    private var timerUpload: Timer?

    /// This delegate allows to return the test interaction information (NDT7TestInteraction protocol).
    public weak var delegate: NDT7TestInteraction?

    /// This parameter contains all the settings needed for ndt7 test.
    public let settings: NDT7Settings

    /// Initialization.
    /// - parameter settings: Contains all the settings needed for ndt7 test.
    public init(settings: NDT7Settings) {
        self.settings = settings
        NDT7Test.ndt7TestInstances.append(WeakRef(self))
    }

    deinit {
        cancel()
        webSocketDownload?.delegate = nil
        webSocketUpload?.delegate = nil
        timerDownload?.invalidate()
        timerUpload?.invalidate()
        timerDownload = nil
        timerUpload = nil
    }
}

/// This extension represent the public function to interact with NDT7Test.
extension NDT7Test {

    /// Start a test
    /// - parameter download: boolean to run download test.
    /// - parameter upload: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the tests. Can returns twice for download and uplod tests.
    public func startTest(download: Bool, upload: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {

        logNDT7("NDT7 test started")

        // Parameters reset.
        downloadMeasurement.removeAll()
        uploadMeasurement.removeAll()
        downloadTestCompletion = nil
        uploadTestCompletion = nil
        timerDownload?.invalidate()
        timerUpload?.invalidate()
        timerDownload = nil
        timerUpload = nil

        // Just one test is allowed to run. Cancel any test in progress.
        NDT7Test.ndt7TestInstances.forEach { $0.object?.cancel() }

        // This timer is a timeout for download test (defined in NDT7Settings).
        timerDownload = Timer.scheduledTimer(withTimeInterval: settings.timeoutTest, repeats: false, block: { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.downloadTestCompletion?(nil)
            strongSelf.downloadTestCompletion = nil
        })
        if let timer = timerDownload {
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }

        // Download test start.
        startDownload(download) { [weak self] (error) in
            guard let strongSelf = self else { return }
            if download, let measurement = strongSelf.downloadMeasurement.last {
                strongSelf.delegate?.downloadMeasurement(measurement)
            }
            if download { strongSelf.downloadTestRunning = false }
            strongSelf.timerDownload?.invalidate()
            strongSelf.timerDownload = nil
            strongSelf.webSocketDownload = nil
            // If the test is cancelled, returns an error with "Test cancelled" and finish the tests.
            // If the test has an error, but is not cancelled, continue with upload test if needed
            // and returns the specific error for download test.
            if let error = error {
                if error.localizedDescription == "Test cancelled" {
                    logNDT7("NDT7 test cancelled")
                    completion(error)
                    return
                }
                completion(error)
            }

            // this timer is a timeout for upload test (defined in NDT7Settings)
            strongSelf.timerUpload = Timer.scheduledTimer(withTimeInterval: strongSelf.settings.timeoutTest, repeats: false, block: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.uploadTestCompletion?(nil)
                strongSelf.uploadTestCompletion = nil
            })
            if let timer = strongSelf.timerUpload {
                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            }

            // Upload test start.
            strongSelf.startUpload(upload) { (error) in
                if upload, let measurement = strongSelf.uploadMeasurement.last {
                    strongSelf.delegate?.uploadMeasurement(measurement)
                }
                if upload { strongSelf.uploadTestRunning = false }
                strongSelf.timerUpload?.invalidate()
                strongSelf.timerUpload = nil
                if let error = error, error.localizedDescription == "Test cancelled" {
                    logNDT7("NDT7 test cancelled")
                } else {
                    logNDT7("NDT7 test finished")
                }
                strongSelf.webSocketUpload = nil
                completion(error)
            }
        }
    }

    /// Cancel test running.
    public func cancel() {
        let error = NSError(domain: "net.measurementlab.NDT7",
                            code: 0,
                            userInfo: [ NSLocalizedDescriptionKey: "Test cancelled"])
        if downloadTestRunning {
            downloadTestCompletion?(error)
            downloadTestCompletion = nil
            webSocketDownload?.close()
        }
        if uploadTestRunning {
            uploadTestCompletion?(error)
            uploadTestCompletion = nil
            webSocketUpload?.close()
        }
        timerDownload?.invalidate()
        timerDownload = nil
        timerUpload?.invalidate()
        timerUpload = nil
        webSocketDownload = nil
        webSocketUpload = nil
    }
}

/// This extension represent the private functions for NDT7Test.
extension NDT7Test {

    /// Start download test
    /// - parameter start: boolean to run download test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the download test.
    private func startDownload(_ start: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start else {
            completion(nil)
            return
        }
        downloadTestCompletion = completion
        logNDT7("Download test setup")
        let url = "\(settings.wss ? "wss" : "ws")\("://")\(settings.hostname)\(settings.downloadPath)"
        if let downloadURL = URL(string: url) {
            webSocketDownload = WebSocketWrapper(settings: settings, url: downloadURL)
            webSocketDownload?.delegate = self
        } else {
            logNDT7("Error with ndt7 settings", .error)
        }
    }

    /// Start upload test
    /// - parameter start: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the upload test.
    private func startUpload(_ start: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start else {
            completion(nil)
            return
        }
        uploadTestRunning = true
        logNDT7("Upload test no functional in the current build.")
        completion(nil)
    }

    /// Handle message returned from server to convert in a NDT7Measurement object.
    /// - parameter message: object returned from server.
    /// - returns: NDT7Measurement with a json text translated to measurement data.
    private func handleMessage(_ message: Any) -> NDT7Measurement? {
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
}

/// This extension provide the web socket interaction.
/// It's used to return data via delegation through delegate object (NDT7TestInteraction).
extension NDT7Test: WebSocketInteraction {

    func open(webSocket: WebSocketWrapper) {
        if webSocket === webSocketDownload {
            downloadTestRunning = true
        } else if webSocket === webSocketUpload {
            uploadTestRunning = true
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
        guard let measurement = handleMessage(message) else { return }
        if webSocket === webSocketDownload {
            logNDT7("Download test \(measurement)")
            downloadMeasurement.append(measurement)
        } else if webSocket === webSocketUpload {
            logNDT7("Upload test \(measurement)")
            uploadMeasurement.append(measurement)
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
