//
//  NDT7.swift
//  NDT7 iOS
//
//  Created by Miguel on 3/29/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// NDT7 provides a framework to measure the download and upload speed.
/// NDT7 is based on WebSocket and TLS, and takes advantage of TCP BBR, where this flavour of TCP is available.
/// NDT7 always uses a single TCP connection.
///
/// NDT7 answers the question of how fast you could pull/push data from your device to a typically-nearby, well-provisioned web server by means of commonly-used web technologies.
/// This is not necessarily a measurement of your last mile speed.
/// Rather it is a measurement of what performance is possible with your device,
/// your current internet connection (landline, Wi-Fi, 4G, etc.),
/// the characteristics of your ISP and possibly of other ISPs in the middle,
/// and the server being used.
/// The main metric measured by ndt7 is the goodput, i.e., the speed measured at application level,
/// without including the overheads of WebSockets, TLS, TCP/IP, and link layer headers.
/// But we also provide kernel-level information from TCP_INFO where available.
/// For all these reasons we say that ndt7 performs application-level measurements.
///
/// The next example shows the whole implementation to get the information from NDT7
/// with a default `NDT7Settings`.
/// Please, check the `NDT7Settings` to undestand the parameters to be able
/// to define for the tests like hostname, paths, etc.
///
/// ```
///import UIKit
///import NDT7
///
///class ViewController: UIViewController {
///
///    var ndt7Test: NDT7Test?
///
///    override func viewDidLoad() {
///        super.viewDidLoad()
///        // For debugging purpose you can enable logs for NDT7 framework.
///        NDT7.loggingEnabled = true
///        startTest()
///    }
///
///    func startTest() {
///        ndt7Test = NDT7Test(settings: NDT7Settings())
///        ndt7Test?.delegate = self
///        ndt7Test?.startTest(download: true, upload: true) { [weak self] (error) in
///            guard self != nil else { return }
///            if let error = error {
///                print("NDT7 iOS Example app - error during test: \(error.localizedDescription)")
///            }
///        }
///    }
///
///    func cancelTest() {
///        ndt7Test?.cancel()
///    }
///}
///
///extension ViewController: NDT7TestInteraction {
///
///    func test(kind: NDT7TestConstants.Kind, running: Bool) {
///    }
///
///    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
///    }
///
///    func error(kind: NDT7TestConstants.Kind, error: NSError) {
///    }
///}
/// ```
///
open class NDT7 {

    /// This parameter allows to enable loggins and check the log messages
    /// for debugging purpose.
    public static var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                LogManager.addAllLogLevels()
                LogManager.addLogger(SystemConsoleLogger())
                logNDT7("Logging Enabled")
            } else {
                logNDT7("Logging Disabled")
                LogManager.removeAllLoggLevels()
                LogManager.removeAllLoggers()
            }
        }
    }
}
