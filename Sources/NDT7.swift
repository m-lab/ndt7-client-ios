//
//  NDT7.swift
//  NDT7 iOS
//
//  Created by Miguel on 3/29/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// NDT7 provides a framework to measure the download and upload speed.
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
///    func downloadTestRunning(_ running: Bool) {
///    }
///
///    func uploadTestRunning(_ running: Bool) {
///    }
///
///    func downloadMeasurement(_ measurement: NDT7Measurement) {
///    }
///
///    func uploadMeasurement(_ measurement: NDT7Measurement) {
///    }
///
///    func downloadTestError(_ error: NSError) {
///    }
///
///    func uploadTestError(_ error: NSError) {
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
