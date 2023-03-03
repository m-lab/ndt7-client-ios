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
    @IBOutlet weak var serverLocationLabel: UILabel!
    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var ndt7Test: NDT7Test?
    var downloadTestRunning: Bool = false
    var uploadTestRunning: Bool = false
    var downloadSpeed: Double?
    var uploadSpeed: Double?
    var dispatchQueue = DispatchQueue(label: "DispatchQueue.NDT7.UpdateUI")
    var enableAppData = true

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
            DispatchQueue.main.async {
                strongSelf.statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
            }
        }
    }

    func cancelTest() {
        ndt7Test?.cancel()
        statusUpdate(downloadTestRunning: false, uploadTestRunning: false)
    }

    func clearData() {
        serverLabel.text = "-"
        serverLocationLabel.text = "-"
        downloadSpeedLabel.text = "-"
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
            cancelButton.alpha = 0
            cancelButton.isEnabled = false
            startButton.alpha = 1
            startButton.isEnabled = true
        } else {
            cancelButton.alpha = 1
            cancelButton.isEnabled = true
            startButton.alpha = 0
            startButton.isEnabled = false
        }
    }
}

extension ViewController: NDT7TestInteraction {

    func test(kind: NDT7TestConstants.Kind, running: Bool) {
        switch kind {
        case .download:
            downloadTestRunning = running
        case .upload:
            uploadTestRunning = running
            statusUpdate(downloadTestRunning: nil, uploadTestRunning: running)
        }
    }

    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        if let server = ndt7Test?.settings.currentServer {
            serverLabel.text = server.machine
            if let serverCountry = server.location?.country,
               let serverCity = server.location?.city
            {
                serverLocationLabel.text = "\(serverCity), \(serverCountry)"
            }
        }

        if origin == .client && kind == .download,
            enableAppData,
            let elapsedTime = measurement.appInfo?.elapsedTime,
            let numBytes = measurement.appInfo?.numBytes,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            let mbit = numBytes / 125000
            let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
            downloadSpeed = rounded
            DispatchQueue.main.async { [weak self] in
                self?.downloadSpeedLabel.text = "\(rounded) Mbit/s"
            }
        } else if origin == .server && kind == .upload,
            let elapsedTime = measurement.tcpInfo?.elapsedTime,
            elapsedTime >= 1000000 {
            let seconds = elapsedTime / 1000000
            if let numBytes = measurement.tcpInfo?.bytesReceived {
                let mbit = numBytes / 125000
                let rounded = Double(Float64(mbit)/Float64(seconds)).rounded(toPlaces: 1)
                uploadSpeed = rounded
                DispatchQueue.main.async { [weak self] in
                    self?.uploadSpeedLabel.text = "\(rounded) Mbit/s"
                }
            }
        }
    }

    func error(kind: NDT7TestConstants.Kind, error: NSError) {
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

extension ViewController {

    func decimalArray(from firstInt: Double, to secondInt: Double) -> [Double] {
        var firstInt = firstInt
        var array: [Double] = []
        if firstInt == secondInt {
            array.insert(firstInt, at: 0)
        } else if firstInt > secondInt {
            let decimals = (firstInt - secondInt) / 10
            while firstInt >= secondInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt -= decimals
            }
        } else if secondInt > firstInt {
            let decimals = (secondInt - firstInt) / 10
            while secondInt >= firstInt {
                array.append(firstInt.rounded(toPlaces: 1))
                firstInt += decimals
            }
        }
        return array
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
