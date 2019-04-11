//
//  SystemConsoleLogger.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/9/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation
import os.log

/// Sends a message to the logging system.
/// The unified logging system provides a single, efficient,
/// performant API for capturing messaging across all levels of the system.
/// This unified system centralizes the storage of log data in memory
/// and in a data store on disk.
/// https://developer.apple.com/documentation/os/logging
class SystemConsoleLogger: Logger {

    static let general = OSLog(subsystem: "net.measurementlab.NDT7", category: "ndt7")

    /// Add a log message to the system console.
    /// - Parameter logMessage: The message to be added.
    func addLogMessage(_ logMessage: LogMessage) {
        os_log("[%{public}@] [%{public}@-%{public}@:%{public}@] (%{public}@) %{public}@",
               log: SystemConsoleLogger.general,
               type: osLogLevel(logMessage.level),
               queueName() ?? "",
               logMessage.file,
               logMessage.function,
               String(logMessage.line),
               logMessage.level.rawValue,
               logMessage.text
               )
    }

    /// `LogLevel` translated to an `OSLogType` type.
    /// - parameter logLevel: The log level to be translated to `OSLogType`.
    /// - returns: A log level for the unified logging system.
    func osLogLevel(_ logLevel: LogLevel) -> OSLogType {

        switch logLevel {
        case .info:
            return .info
        case .debug:
            return .debug
        case .warning:
            return .error
        case .error:
            return .fault
        }
    }
}
