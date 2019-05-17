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

    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var downloadTime: UILabel!
    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var maxBandwidthLabel: UILabel!
    @IBOutlet weak var minRTTLabel: UILabel!
    @IBOutlet weak var smoothedRTTLabel: UILabel!
    @IBOutlet weak var rttVarianceLabel: UILabel!
    @IBOutlet weak var uploadTime: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var ndt7Test: NDT7Test?
    var downloadTestRunning: Bool = false
    var uploadTestRunning: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NDT7.loggingEnabled = true
        cancelButton.alpha = 0
        cancelButton.isEnabled = false
    }

    func startTest() {
        clearData()
        let settings = NDT7Settings()
        ndt7Test = NDT7Test(settings: settings)
        ndt7Test?.delegate = self
        statusUpdate(downloadTestRunning: true, uploadTestRunning: true)
        ndt7Test?.startTest(download: true, upload: true) { [weak self] (error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.errorAlert(title: "Error during tests", message: "\(error.localizedDescription)")
            }
            strongSelf.statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
        }
    }

    func cancelTest() {
        ndt7Test?.cancel()
    }

    func clearData() {
        serverLabel.text = "-"
        downloadTime.text = "-"
        downloadSpeedLabel.text = "-"
        maxBandwidthLabel.text = "-"
        minRTTLabel.text = "-"
        smoothedRTTLabel.text = "-"
        rttVarianceLabel.text = "-"
        uploadTime.text = "-"
        uploadSpeedLabel.text = "-"
    }

    @IBAction func startButtonAction(_ sender: Any) {
        startTest()
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        cancelTest()
    }
}

extension ViewController {

    func statusUpdate(downloadTestRunning: Bool?, uploadTestRunning: Bool?) {
        if let downloadTestRunning = downloadTestRunning {
            self.downloadTestRunning = downloadTestRunning
        }
        if let uploadTestRunning = uploadTestRunning {
            self.uploadTestRunning = uploadTestRunning
        }
        if self.downloadTestRunning == false && self.uploadTestRunning == false {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.cancelButton.alpha = 0
                strongSelf.cancelButton.isEnabled = false
                strongSelf.startButton.alpha = 1
                strongSelf.startButton.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.cancelButton.alpha = 1
                strongSelf.cancelButton.isEnabled = true
                strongSelf.startButton.alpha = 0
                strongSelf.startButton.isEnabled = false
            }
        }
    }
}

extension ViewController: NDT7TestInteraction {

    func downloadTestRunning(_ running: Bool) {
        downloadTestRunning = running
    }

    func uploadTestRunning(_ running: Bool) {
        uploadTestRunning = running
        statusUpdate(downloadTestRunning: nil, uploadTestRunning: running)
    }

    func downloadMeasurement(_ measurement: NDT7Measurement) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let url = strongSelf.ndt7Test?.settings.url.hostname {
                strongSelf.serverLabel.text = url
            }
            if let elapsedTime = measurement.elapsed {
                strongSelf.downloadTime.text = "\(String(Int(elapsedTime))) s"
                if let maxBandwidth = measurement.bbrInfo?.bandwith {
                    let rounded = Double(Float64(maxBandwidth)/elapsedTime/125000).rounded(toPlaces: 3)
                    strongSelf.maxBandwidthLabel.text = "\(rounded) Mbit/s"
                }
                if let downloadSpeed = measurement.appInfo?.numBytes {
                    let rounded = Double(Float64(downloadSpeed)/elapsedTime/125000).rounded(toPlaces: 3)
                    strongSelf.downloadSpeedLabel.text = "\(rounded) Mbit/s"
                }
            }
            if let minRTT = measurement.bbrInfo?.minRtt {
                strongSelf.minRTTLabel.text = "\(minRTT) ms"
            }
            if let smoothedRTT = measurement.tcpInfo?.smoothedRtt {
                strongSelf.smoothedRTTLabel.text = "\(smoothedRTT) ms"
            }
            if let rttVariance = measurement.tcpInfo?.rttVar {
                strongSelf.rttVarianceLabel.text = "\(rttVariance) ms"
            }
        }
    }

    func uploadMeasurement(_ measurement: NDT7Measurement) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let url = strongSelf.ndt7Test?.settings.url.hostname {
                strongSelf.serverLabel.text = url
            }
            if let elapsedTime = measurement.elapsed, let uploadSpeed = measurement.appInfo?.numBytes {
                strongSelf.uploadTime.text = "\(String(Int(elapsedTime))) s"
                let rounded = Double(Float64(uploadSpeed)/elapsedTime/125000).rounded(toPlaces: 3)
                strongSelf.uploadSpeedLabel.text = "\(rounded) Mbit/s"
            }
        }
    }

    func downloadTestError(_ error: NSError) {
        cancelTest()
    }

    func uploadTestError(_ error: NSError) {
        cancelTest()
    }

    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            strongSelf.present(alert, animated: true)
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
