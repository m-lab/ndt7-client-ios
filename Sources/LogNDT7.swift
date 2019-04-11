//
//  LogNDT7.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/8/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

// MARK: Log Levels.

/// Different type of messages.
enum LogLevel: String {

    /// Helpful information (no error or issue).
    case info

    /// For debugging during development process.
    case debug

    /// It can become an error.
    case warning

    /// Critical errors and failures.
    case error
}

// MARK: Log Message.

/// All the useful information for a log message.
struct LogMessage {

    /// The date and time at which the log message was created.
    let date: Date = Date()

    /// The level of the log message.
    let level: LogLevel

    /// The file where the log message was created.
    let file: String

    /// The function where the log message was created.
    let function: String

    /// The line where the log message was invoked in the source code.
    let line: Int

    /// The text message of the log.
    let text: String

    init(text: String, level: LogLevel, file: String, function: String, line: Int) {
        self.text = text
        self.level = level
        self.file = file.components(separatedBy: "/").last ?? file
        self.function = function
        self.line = line
    }

    /// log message description for NDT7.
    /// - returns: The log message description.
    func ndt7Description() -> String {
        let logDate = date.toString()
        let queName = queueName() ?? ""
        let logLevel = level.rawValue
        return "\(logDate) [ndt7] [\(queName)] [\(file )-\(function):\(line)]: (\(logLevel)) \(text)"
    }
}

// MARK: Logger Protocol.

/// Classes that conform this protocol should be able to add a log message.
protocol Logger {

    /// Add a log message
    /// - parameter logMessage: The message to be added.
    func addLogMessage(_ logMessage: LogMessage)
}

// MARK: Log Manager.

/// Manage log messages, loggers and log levels.
class LogManager {

    private static var loggers = [Logger]()
    private static var logLevels = Set<LogLevel>()

    /// Add a logger to loggers.
    /// - parameter: The logger to be added.
    class func addLogger(_ logger: Logger) {
        loggers.append(logger)
    }

    /// Remove all the loggers.
    class func removeAllLoggers() {
        loggers.removeAll()
    }

    /// Add a Log Level to manage.
    /// - parameter logLevel: The log level to be added.
    class func addLogLevel(_ logLevel: LogLevel) {
        logLevels.insert(logLevel)
    }

    /// Add all the Log Levels.
    class func addAllLogLevels() {
        logLevels.insert(.info)
        logLevels.insert(.debug)
        logLevels.insert(.warning)
        logLevels.insert(.error)
    }

    /// Remove Log Level to manage.
    /// - parameter logLevel: The log level to be removed.
    class func removeLogLevel(_ logLevel: LogLevel) {
        logLevels.remove(logLevel)
    }

    /// Remove all Log Levels.
    class func removeAllLoggLevels() {
        logLevels.removeAll()
    }

    /// Add a log message to the loggers if the log level is managed.
    /// - parameter logMessage: The log message to be added to the loggers.
    class func addLogMessage(_ logMessage: LogMessage) {
        guard logLevels.contains(logMessage.level) else { return }
        loggers.forEach { $0.addLogMessage(logMessage) }
    }
}

/// MARK: logNDT7.

func logNDT7(_ text: @autoclosure () -> Any,
             _ logLevel: LogLevel = .info,
             _ file: String = #file,
             _ function: String = #function,
             _ line: Int = #line) {
    LogManager.addLogMessage(LogMessage(text: "\(text())", level: logLevel, file: file, function: function, line: line))
}
