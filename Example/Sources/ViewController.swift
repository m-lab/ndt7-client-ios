//
//  ViewController.swift
//  NDT7 iOS Example
//
//  Created by Miguel on 3/29/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import UIKit
import NDT7

class ViewController: UIViewController {

    var ndt7Test: NDT7Test?

    override func viewDidLoad() {
        super.viewDidLoad()
        NDT7.loggingEnabled = true
        startTest()
    }

    func startTest() {
        print("NDT7 iOS Example app - download and upload test started")
        ndt7Test = NDT7Test(settings: NDT7Settings())
        ndt7Test?.delegate = self
        ndt7Test?.startTest(download: false, upload: true) { [weak self] (error) in
            guard self != nil else { return }
            if let error = error {
                print("NDT7 iOS Example app - error during test: \(error.localizedDescription)")
            } else {
                print("NDT7 iOS Example app - test finished.")
            }
        }
    }

    func cancelTest() {
        print("NDT7 iOS Example app - download and upload test cancel")
        ndt7Test?.cancel()
    }
}

extension ViewController: NDT7TestInteraction {

    func downloadTestRunning(_ running: Bool) {
        print("NDT7 iOS Example app - download test running: \(running)")
    }

    func uploadTestRunning(_ running: Bool) {
        print("NDT7 iOS Example app - upload test running: \(running)")
    }

    func downloadMeasurement(_ measurement: NDT7Measurement) {
        print("NDT7 iOS Example app - download test measurement: \"\(measurement)\"")
    }

    func uploadMeasurement(_ measurement: NDT7Measurement) {
        print("NDT7 iOS Example app - upload test measurement: \"\(measurement)\"")
    }

    func downloadTestError(_ error: NSError) {
        print("NDT7 iOS Example app - download test error: \(error.localizedDescription)")
    }

    func uploadTestError(_ error: NSError) {
        print("NDT7 iOS Example app - upload test error: \(error.localizedDescription)")
    }
}
