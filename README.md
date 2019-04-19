# NDT7 iOS

| branch | travis-ci | codacy | sonarcloud | codecov |
|--------|-----------|--------|------------|---------|
| develop | [![Build Status](https://travis-ci.org/m-lab/ndt7-client-ios.svg?branch=develop)](https://travis-ci.org/m-lab/ndt7-client-ios) | | | [![Coverage Status](https://codecov.io/gh/m-lab/ndt7-client-ios/branch/develop/graphs/badge.svg)](https://codecov.io/gh/m-lab/ndt7-client-ios/branch/develop) |
| master | [![Build Status](https://travis-ci.org/m-lab/ndt7-client-ios.svg?branch=master)](https://travis-ci.org/m-lab/ndt7-client-ios) | [![Codacy Badge](https://api.codacy.com/project/badge/Grade/979506f489c944348dc7d6c51586eb08)](https://www.codacy.com/app/miguelangelnet/ndt7-client-ios?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=m-lab/ndt7-client-ios&amp;utm_campaign=Badge_Grade) | [![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=alert_status)](https://sonarcloud.io/dashboard/index/m-lab_ndt7-client-ios) | [![Coverage Status](https://codecov.io/gh/m-lab/ndt7-client-ios/branch/master/graphs/badge.svg)](https://codecov.io/gh/m-lab/ndt7-client-ios/branch/master) |

[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=bugs)](https://sonarcloud.io/component_measures?id=m-lab_ndt7-client-ios&metric=Reliability)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=vulnerabilities)](https://sonarcloud.io/component_measures?id=m-lab_ndt7-client-ios&metric=Security)
[![Maintainability](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=sqale_rating)](https://sonarcloud.io/component_measures?id=m-lab_ndt7-client-ios&metric=Maintainability)
[![Reliability](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=reliability_rating)](https://sonarcloud.io/component_measures?id=m-lab_ndt7-client-ios&metric=Reliability)
[![Security](https://sonarcloud.io/api/project_badges/measure?project=m-lab_ndt7-client-ios&metric=security_rating)](https://sonarcloud.io/component_measures?id=m-lab_ndt7-client-ios&metric=Security)

[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/m-lab/ndt7-client-ios.svg)](http://isitmaintained.com/project/m-lab/ndt7-client-ios "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/m-lab/ndt7-client-ios.svg)](http://isitmaintained.com/project/m-lab/ndt7-client-ios "Percentage of issues still open")
[![Measurement Lab](https://img.shields.io/badge/Measurement%20Lab-purple.svg)](https://www.measurementlab.net/)
[![Apache License](https://img.shields.io/github/license/m-lab/ndt7-client-ios.svg)](http://www.apache.org/licenses/LICENSE-2.0)

# Table of Contents

<!-- MarkdownTOC -->

- [Introduction](#introduction)
    - [Current supported features](#current-supported-features)
- [Requirements](#requirements)
- [Documentation](#documentation)
- [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
    - [Manual Installation](#manual-installation)
- [Setup and Usage](#setup-and-usage)
    - [Setup](#setup)
    - [Start speed test](#start-speed-test)
- [License](#license)

<!-- /MarkdownTOC -->

<a name="introduction"></a>
# Introduction

"Measure the Internet, save the data, and make it universally accessible and useful."

NDT7 provides a framework to measure the download and upload speed.

<a name="current-supported-features"></a>
## Current supported features

- [X] Download Speed Test. Beta version.
- [ ] Download Speed Test
- [ ] Upload Speed Test

<a name="requirements"></a>
# Requirements

- iOS 10.0+ / macOS 10.14.0+ / appleTV 10.0+ / watchOS 3.0+
- Xcode 10.2+
- Swift 5.0+

<a name="documentation"></a>
# Documentation

Visit the `NDT7` [documentation](http://htmlpreview.github.io/?https://github.com/m-lab/ndt7-client-ios/blob/master/docs/index.html) for instructions and browsing api references.

<a name="installation"></a>
# Installation

<a name="cocoapods"></a>
## CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website.

**Not supported yet.**

<a name="carthage"></a>
## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

**Not supported yet.**

<a name="manual-installation"></a>
## Manual Installation

**Documentation in progress.**

<a name="setup-and-usage"></a>
# Setup and usage

<a name="setup"></a>
## Setup

The only setup needed for debugging purpose is to enable logging if needed.
```
NDT7.loggingEnabled = true
```

If specific settings are needed for the testing configuration, you can define an NDT7Settings object, otherwise, use the default one with NDT7Settings().

In the next section, "Start speed test", we'll show all the steps needed to start a test.

<a name="start-speed-test"></a>
## Start speed test

The next example show the whole process for a download and upload speed test.
1. Setup all the functions needed for NDT7Test delegate.
2. Create the settings for testing. NDT7Settings.
3. Create a NDT7Test object with NDT7Settings already created.
4. Setup a delegation for NDT7Test to get the test information.
5. Start speed test for download and/or upload.

```
import UIKit
import NDT7

class ViewController: UIViewController {

    var ndt7Test: NDT7Test?

    override func viewDidLoad() {
        super.viewDidLoad()
        // For debugging purpose you can enable logs for NDT7 framework.
        NDT7.loggingEnabled = true
        startTest()
    }

    func startTest() {
        // 2. Create the settings for testing. NDT7Settings.
        let settings = NDT7Settings()
        // 3. Create a NDT7Test object with NDT7Settings already created.
        ndt7Test = NDT7Test(settings: settings)
        // 4. Setup a delegation for NDT7Test to get the test information.
        ndt7Test?.delegate = self
        // 5. Start speed test for download and/or upload.
        ndt7Test?.startTest(download: true, upload: true) { [weak self] (error) in
            guard self != nil else { return }
            if let error = error {
                print("NDT7 iOS Example app - Error during test: \(error.localizedDescription)")
            } else {
                print("NDT7 iOS Example app - Test finished.")
            }
        }
    }

    func cancelTest() {
        ndt7Test?.cancel()
    }
}

// 1. Setup all the functions needed for NDT7Test delegate.
extension ViewController: NDT7TestInteraction {

    func downloadTestRunning(_ running: Bool) {
    }

    func uploadTestRunning(_ running: Bool) {
    }

    func downloadMeasurement(_ measurement: NDT7Measurement) {
    }

    func uploadMeasurement(_ measurement: NDT7Measurement) {
    }

    func downloadTestError(_ error: NSError) {
    }

    func uploadTestError(_ error: NSError) {
    }
}
```

# License

`NDT7` iOS client is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See LICENSE for details.
