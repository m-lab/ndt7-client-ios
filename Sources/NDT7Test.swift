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

    /// Provide the status of download and upload test
    /// - parameter kind: Kind of test.
    /// - parameter running: true if the test is running, otherwise, false.
    func test(kind: NDT7TestConstants.Kind, running: Bool)

    /// Provide the measurement of download and upload test
    /// - parameter origin: Origin of the test.
    /// - parameter kind: Kind of test.
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement)

    /// Error returned if something happen during a download test.
    /// - parameter kind: Kind of test.
    /// - parameter error: Error during the test.
    func error(kind: NDT7TestConstants.Kind, error: NSError)
}

/// This extension for NDT7TestInteraction protocol allows to have optional functions.
/// The information is returned in the main thread.
extension NDT7TestInteraction {

    /// Convert protocol test function in optional
    /// - parameter kind: Kind of test.
    /// - parameter running: true if the test is running, otherwise, false.
    public func test(kind: NDT7TestConstants.Kind, running: Bool) {
        // Empty function for default implementation.
    }

    /// Convert protocol measurement function in optional
    /// - parameter origin: Origin of the test.
    /// - parameter kind: Kind of test.
    /// - parameter measurement: Provide the measurement via `NDT7Measurement`, please check `NDT7Measurement` to get more information about the parameters the measurement contain.
    public func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        // Empty function for default implementation.
    }

    /// Convert protocol error function in optional
    /// - parameter kind: Kind of test.
    /// - parameter error: Error during the test.
    public func error(kind: NDT7TestConstants.Kind, error: NSError) {
        // Empty function for default implementation.
    }
}

/// NDT7Test describes the version 7 of the Network Diagnostic Tool (NDT) protocol (ndt7).
/// It is a redesign of the original NDT network performance measurement protocol.
/// NDT7Test is based on WebSocket and TLS, and takes advantage of TCP BBR, where this flavour of TCP is available.
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
                delegate?.test(kind: .download, running: downloadTestRunning)
            }
        }
    }

    /// Upload test running parameter. True if it is running, otherwise, false.
    var uploadTestRunning: Bool = false {
        didSet {
            if uploadTestRunning != oldValue {
                logNDT7("Upload test running: \(uploadTestRunning)")
                delegate?.test(kind: .upload, running: uploadTestRunning)
            }
        }
    }
    var webSocketDownload: WebSocketWrapper?
    var webSocketUpload: WebSocketWrapper?
    var downloadTestCompletion: ((_ error: NSError?) -> Void)?
    var uploadTestCompletion: ((_ error: NSError?) -> Void)?
    var timerDownload: Timer?
    var timerUpload: Timer?
    var discoverServerTask: URLSessionTaskNDT7?
    var t0Download: Date?
    var tLastDownload: Date?

    /// This delegate allows to return the test interaction information (`NDT7TestInteraction` protocol).
    public weak var delegate: NDT7TestInteraction?

    /// This parameter contains all the settings needed for ndt7 test.
    /// Please, check `NDT7Settings` for more information about the settings.
    public var settings: NDT7Settings

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

    /// MLab server setup for testing and
    /// start a test for download and/or upload, returning error if something was wrong.
    /// - parameter download: boolean to run download test.
    /// - parameter upload: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error if it happens during the tests.
    public func startTest(download: Bool, upload: Bool, _ completion: @escaping (_ error: NSError?) -> Void) {
        logNDT7("NDT7 test started")
        cleanup()
        NDT7Test.ndt7TestInstances.forEach { $0.object?.cancel() }
        serverSetup(session: Networking.shared.session, { [weak self] (error) in
            OperationQueue.current?.name = "net.measurementlab.NDT7.test"
            self?.test(download: download, upload: upload, error: error, completion)
        })
    }

    /// Server setup discover a MLab server for testing if there is not hostname deffined in settings.
    /// - parameter completion: closure for callback.
    /// - parameter servers: An array of NDT7Servers that were located with Locate API.
    /// - parameter error: returns an error if exists.
    func serverSetup<T: URLSessionNDT7>(session: T = URLSession.shared as! T,
                                        _ completion: @escaping (_ error: NSError?) -> Void) {
        discoverServerTask = NDT7Server.discover(session: session,
                                                 retry: 4, { [weak self] (servers, error) in
            guard error == nil else {
                completion(error)
                return
            }
            guard let servers = servers, !servers.isEmpty else {
                let discoveryError = NSError(domain: NDT7WebSocketConstants.domain,
                                             code: 0,
                                             userInfo: [ NSLocalizedDescriptionKey: "Failed to locate a valid MLab server to contact"])
                completion(discoveryError)
                return
            }
            guard let strongSelf = self else { return }

            strongSelf.settings.allServers = servers
            strongSelf.settings.currentServerIndex = 0
            completion(error)
        })
    }

    /// Start a test for download and/or upload, returning error if something was wrong.
    /// - parameter download: boolean to run download test.
    /// - parameter upload: boolean to run upload test.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error if it happens during the tests.
    func test(download: Bool, upload: Bool, error: NSError?, _ completion: @escaping (_ error: NSError?) -> Void) {
        startDownload(download, error: error) { [weak self] (error) in
            self?.cleanup()
            mainThread {
                self?.downloadTestRunning = false
            }
            self?.startUpload(upload, error: error) { (error) in
                self?.cleanup()
                mainThread {
                    self?.uploadTestRunning = false
                }
                logNDT7("NDT7 test finished")
                completion(error)
            }
        }
    }

    /// Cancel test running.
    public func cancel() {
        if discoverServerTask?.state == URLSessionTask.State.running {
            discoverServerTask?.cancel()
        }
        if downloadTestRunning {
            downloadTestCompletion?(NDT7TestConstants.cancelledError)
            downloadTestCompletion = nil
        }
        if uploadTestRunning {
            uploadTestCompletion?(NDT7TestConstants.cancelledError)
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
    /// - parameter error: error to return if exist.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the download test.
    func startDownload(_ start: Bool, error: NSError?, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start && error == nil else {
            completion(error)
            return
        }
        downloadTestCompletion = completion
        logNDT7("Download test setup")
        guard let downloadURL = settings.currentDownloadURL else {
            logNDT7("Error with ndt7 download settings", .error)
            let noDownloadURL = NSError(domain: NDT7WebSocketConstants.domain,
                                        code: 0,
                                        userInfo: [ NSLocalizedDescriptionKey: "MLab server does not have an download URL."])
            completion(noDownloadURL)
            return
        }
        timerDownload?.invalidate()
        timerDownload = Timer.scheduledTimer(withTimeInterval: settings.timeout.downloadTimeout,
                                             repeats: false,
                                             block: { [weak self] (_) in
                                                self?.downloadTestCompletion?(nil)
                                                self?.downloadTestCompletion = nil
                                             })
        RunLoop.main.add(timerDownload!, forMode: RunLoop.Mode.common)
        webSocketDownload = WebSocketWrapper(settings: settings, url: downloadURL)
        webSocketDownload?.delegate = self
    }

    /// Start upload test
    /// - parameter start: boolean to run upload test.
    /// - parameter error: error to return if exist.
    /// - parameter completion: A block to execute.
    /// - parameter error: Contains an error during the upload test.
    func startUpload(_ start: Bool, error: NSError?, _ completion: @escaping (_ error: NSError?) -> Void) {
        guard start && error == nil else {
            completion(error)
            return
        }
        uploadTestCompletion = completion
        logNDT7("Upload test setup")
        guard let uploadURL = settings.currentUploadURL else {
            logNDT7("Error with ndt7 upload settings", .error)
            let noUploadURL = NSError(domain: NDT7WebSocketConstants.domain,
                                      code: 0,
                                      userInfo: [ NSLocalizedDescriptionKey: "MLab server does not have an upload URL."])
            completion(noUploadURL)
            return
        }
        timerUpload?.invalidate()
        timerUpload = Timer.scheduledTimer(withTimeInterval: settings.timeout.uploadTimeout,
                                           repeats: false,
                                           block: { [weak self] (_) in
                                            self?.uploadTestCompletion?(nil)
                                            self?.uploadTestCompletion = nil
                                           })
        RunLoop.main.add(timerUpload!, forMode: RunLoop.Mode.common)
        webSocketUpload = WebSocketWrapper(settings: settings, url: uploadURL)
        webSocketUpload?.delegate = self
    }

    /// Uploader is a function to upload messages to the server to meassure the upload speed.
    /// - parameter socket: WebSocket object in charge of the upload.
    /// - parameter message: Data message to upload.
    /// - parameter t0: Initial date time or nil to indicate the first iteration.
    /// - parameter tlast: Last date time or nil to indicate the first iteration.
    /// - parameter count: Number of transmitted bytes.
    /// - parameter queue: Dispatch queue for upload.
    func uploader(socket: WebSocketWrapper, message: Data, t0: Date?, tlast: Date?, count: Int, queue: DispatchQueue) {

        let t0 = t0 ?? Date()
        var t1 = Date()
        var tlast = tlast ?? Date()
        var count = count
        let duration: TimeInterval = 10.0
        guard t1.timeIntervalSince1970 - t0.timeIntervalSince1970 < duration && uploadTestRunning == true else {
            uploadMessage(socket: socket, t0: t0, t1: t1, count: webSocketUpload?.outputBytesLengthAccumulated ?? 0)
            uploadTestCompletion?(nil)
            uploadTestCompletion = nil
            return
        }

        let underbuffered = 7 * message.count
        var buffered: Int? = 0
        if t1.timeIntervalSince1970 - tlast.timeIntervalSince1970 > 0.25,
           let outputBytesAccumulated = webSocketUpload?.outputBytesLengthAccumulated {
            tlast = t1
            uploadMessage(socket: socket, t0: t0, t1: t1, count: outputBytesAccumulated)
        }
        while buffered != nil && buffered! < underbuffered && t1.timeIntervalSince1970 - t0.timeIntervalSince1970 < duration && uploadTestRunning == true,
              let outputBytesAccumulated = webSocketUpload?.outputBytesLengthAccumulated,
              count < outputBytesAccumulated + underbuffered {
            buffered = socket.send(message, maxBuffer: underbuffered)
            if buffered != nil {
                count += message.count * Int(NDT7WebSocketConstants.Request.maxConcurrentMessages)
            }
            t1 = Date()
            if t1.timeIntervalSince1970 - tlast.timeIntervalSince1970 > 0.25 {
                tlast = t1
                uploadMessage(socket: socket, t0: t0, t1: t1, count: outputBytesAccumulated)
            }
        }
        queue.asyncAfter(deadline: .now() + NDT7WebSocketConstants.Request.uploadRequestDelay) { [weak self] in
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
        let message = "{ }"
        if var measurement = handleMessage(message) {
            measurement.origin = .client
            measurement.direction = .upload
            measurement.appInfo = NDT7APPInfo(elapsedTime: Int64((t1.timeIntervalSince1970 * 1000000.0) - (t0.timeIntervalSince1970 * 1000000.0)), numBytes: Int64(count))
            if let jsonData = try? JSONEncoder().encode(measurement) {
                measurement.rawData = String(data: jsonData, encoding: .utf8)
            }
            logNDT7("Upload test from client: \(measurement.rawData ?? "")")
            mainThread { [weak self] in
                self?.delegate?.measurement(origin: .client, kind: .upload, measurement: measurement)
            }
        }
    }

    /// Handle message returned from server to convert in a NDT7Measurement object.
    /// - parameter message: object returned from server.
    /// - returns: NDT7Measurement with a json text translated to measurement data.
    func handleMessage(_ message: Any) -> NDT7Measurement? {
        if let message = message as? String, let data = message.data(using: .utf8) {
            do {
                var decoded = try JSONDecoder().decode(NDT7Measurement.self, from: data)
                decoded.rawData = message
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
            t0Download = Date()
            tLastDownload = Date()
            mainThread { [weak self] in
                self?.downloadTestRunning = true
            }
        } else if webSocket === webSocketUpload {
            mainThread { [weak self] in
                self?.uploadTestRunning = true
            }
            let dispatchQueue = DispatchQueue.init(label: "net.measurementlab.NDT7.upload.test", qos: .userInteractive)
            dispatchQueue.async { [weak self] in
                self?.uploader(socket: webSocket, message: Data.randomDataNetworkElement(), t0: nil, tlast: nil, count: 0, queue: dispatchQueue)
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
            measurement.origin = .server
            measurement.direction = .download
            logNDT7("Download test from server: \(measurement.rawData ?? "")")
            mainThread { [weak self] in
                self?.delegate?.measurement(origin: .server, kind: .download, measurement: measurement)
            }
            let t1 = Date()
            if let tLast = tLastDownload,
               let t0 = t0Download,
               t1.timeIntervalSince1970 - tLast.timeIntervalSince1970 > 0.25 {
                tLastDownload = t1
                let elapsedTime = Int64(((t1.timeIntervalSince1970 * 1000000.0) - (t0.timeIntervalSince1970 * 1000000.0)))
                let appInfo = NDT7APPInfo(elapsedTime: elapsedTime, numBytes: Int64(webSocket.inputBytesLengthAccumulated))
                var clientMeasurement = NDT7Measurement(appInfo: appInfo,
                                                        bbrInfo: nil,
                                                        connectionInfo: nil,
                                                        origin: .client,
                                                        direction: .download,
                                                        tcpInfo: nil,
                                                        rawData: nil)
                if let jsonData = try? JSONEncoder().encode(clientMeasurement) {
                    clientMeasurement.rawData = String(data: jsonData, encoding: .utf8)
                }
                logNDT7("Download test from client: \(clientMeasurement.rawData ?? "")")
                mainThread { [weak self] in
                    self?.delegate?.measurement(origin: .client, kind: .download, measurement: clientMeasurement)
                }
            }
        } else if webSocket === webSocketUpload {
            measurement.origin = .server
            measurement.direction = .upload
            logNDT7("Upload test from server: \(measurement.rawData ?? "")")
            mainThread { [weak self] in
                self?.delegate?.measurement(origin: .server, kind: .upload, measurement: measurement)
            }
        }
    }

    func error(webSocket: WebSocketWrapper, error: NSError) {
        let mLabServerError = NSError(domain: NDT7WebSocketConstants.domain,
                                      code: 0,
                                      userInfo: [ NSLocalizedDescriptionKey: "MLab server \(settings.currentServer?.machine ?? "") has an error during test"])
        if webSocket === webSocketDownload {
            logNDT7("Download test error: \(error.localizedDescription)", .error)
            mainThread { [weak self] in
                self?.delegate?.error(kind: .download, error: mLabServerError)
            }
            downloadTestCompletion?(mLabServerError)
            downloadTestCompletion = nil
        } else if webSocket === webSocketUpload {
            logNDT7("Upload test error: \(error.localizedDescription)", .error)
            mainThread { [weak self] in
                self?.delegate?.error(kind: .upload, error: mLabServerError)
            }
            uploadTestCompletion?(mLabServerError)
            uploadTestCompletion = nil
        }
    }
}
