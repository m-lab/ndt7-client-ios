//
//  DebugConsoleLogger.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/8/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Uses the Debug Console to show the log messages.
class DebugConsoleLogger: Logger {

    /// Add a log message to print in the debug console.
    /// - parameter logMessage: The message to be added to the debug console.
    func addLogMessage(_ logMessage: LogMessage) {
        print("\(logMessage.ndt7Description())")
    }
}
