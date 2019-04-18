//
//  NDT7.swift
//  NDT7 iOS
//
//  Created by Miguel on 3/29/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// NDT7.
open class NDT7 {

    /// This parameter allows to enable loggins and check the log messages.
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
