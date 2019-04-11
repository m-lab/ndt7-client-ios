//
//  LogNDT7Tests.swift
//  NDT7 iOS Tests
//
//  Created by Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation
import XCTest
@testable import NDT7

class LogMessageTests: XCTestCase {

    var logMessage: LogMessage!
    var logMessageWithSlash: LogMessage!

    override func setUp() {

        let text = "text"
        let level: LogLevel = .debug
        let file = #file
        let function = #function
        let line = #line
        logMessage = LogMessage(text: text, level: level, file: file, function: function, line: line)

        let fileWithSlash = "/text/file.swift"
        logMessageWithSlash = LogMessage(text: text, level: level, file: fileWithSlash, function: function, line: line)
    }

    func testInitLogMessage() {

        XCTAssertEqual(logMessage.file, "LogNDT7Tests.swift")
        XCTAssertEqual(logMessageWithSlash.file, "file.swift")
    }

    func testLogMessageNDT7Description() {

        XCTAssertTrue(logMessage.ndt7Description().contains("[ndt7] [com.apple.main-thread] [LogNDT7Tests.swift-setUp():24]: (debug) text"))
        XCTAssertTrue(logMessageWithSlash.ndt7Description().contains("[ndt7] [com.apple.main-thread] [file.swift-setUp():24]: (debug) text"))
    }
}

class LoggerTests: XCTestCase {

    class MockLogger: Logger {

        var logMessage: [LogMessage] = []

        func addLogMessage(_ logMessage: LogMessage) {
            self.logMessage.append(logMessage)
        }
    }

    var mockLogger1: MockLogger!
    var mockLogger2: MockLogger!
    var logMessage: LogMessage!

    override func setUp() {

        mockLogger1 = MockLogger()
        mockLogger2 = MockLogger()
        let text = "text"
        let level: LogLevel = .debug
        let file = #file
        let function = #function
        let line = #line
        logMessage = LogMessage(text: text, level: level, file: file, function: function, line: line)
    }

    override func tearDown() {

        LogManager.removeAllLoggers()
        LogManager.removeAllLoggLevels()
    }

    func testLogMessageWithLogManagerWithoutLoggerAndWithoutLogLevel() {

        LogManager.addLogMessage(logMessage)
        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)
    }

    func testLogMessageWithLogManagerWithLoggerAndWithoutLogLevel() {

        LogManager.addLogger(mockLogger1)
        LogManager.addLogger(mockLogger2)
        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)
    }

    func testLogMessageWithLogManagerWithLoggerAndWithLogLevel() {

        LogManager.addLogger(mockLogger1)
        LogManager.addLogger(mockLogger2)
        LogManager.addLogLevel(.info)
        LogManager.addLogLevel(.error)
        LogManager.addLogLevel(.warning)

        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)

        LogManager.addLogMessage(logMessage)
        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)

        LogManager.addLogLevel(.debug)
        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)

        LogManager.addLogMessage(logMessage)
        LogManager.addLogMessage(logMessage)
        XCTAssertEqual(mockLogger1.logMessage.count, 2)
        XCTAssertEqual(mockLogger2.logMessage.count, 2)
        XCTAssertEqual(mockLogger1.logMessage.first?.text, "text")
        XCTAssertEqual(mockLogger1.logMessage.first?.level, .debug)
        XCTAssertEqual(mockLogger1.logMessage.first?.file, "LogNDT7Tests.swift")
        XCTAssertEqual(mockLogger1.logMessage.first?.function, "setUp()")
        XCTAssertEqual(mockLogger1.logMessage.first?.line, 67)
        XCTAssertEqual(mockLogger2.logMessage.first?.text, "text")
        XCTAssertEqual(mockLogger2.logMessage.first?.level, .debug)
        XCTAssertEqual(mockLogger2.logMessage.first?.file, "LogNDT7Tests.swift")
        XCTAssertEqual(mockLogger2.logMessage.first?.function, "setUp()")
        XCTAssertEqual(mockLogger2.logMessage.first?.line, 67)
    }
}

class LogNDT7Tests: XCTestCase {

    class MockLogger: Logger {

        var logMessage: [LogMessage] = []

        func addLogMessage(_ logMessage: LogMessage) {
            self.logMessage.append(logMessage)
        }
    }

    var mockLogger1: MockLogger!
    var mockLogger2: MockLogger!

    override func setUp() {

        mockLogger1 = MockLogger()
        mockLogger2 = MockLogger()
        LogManager.removeAllLoggers()
        LogManager.removeAllLoggLevels()
    }

    override func tearDown() {

        LogManager.removeAllLoggers()
        LogManager.removeAllLoggLevels()
    }

    func testLogMessageWithLogManagerWithoutLoggerAndWithoutLogLevel() {

        logNDT7("test log level")
        logNDT7("test info log level", .info)
        logNDT7("test debug log level", .debug)
        logNDT7("test warning log level", .warning)
        logNDT7("test error log level", .error)

        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)
    }

    func testLogMessageWithLogManagerWithLoggerAndWithoutLogLevel() {

        LogManager.addLogger(mockLogger1)
        LogManager.addLogger(mockLogger2)

        logNDT7("test log level")
        logNDT7("test info log level", .info)
        logNDT7("test debug log level", .debug)
        logNDT7("test warning log level", .warning)
        logNDT7("test error log level", .error)

        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)
    }

    func testLogMessageWithLogManagerWithLoggerAndWithLogLevel() {

        LogManager.addLogger(mockLogger1)
        LogManager.addLogger(mockLogger2)

        LogManager.addLogLevel(.info)
        LogManager.addLogLevel(.error)

        logNDT7("test warning log level", .warning)

        XCTAssertTrue(mockLogger1.logMessage.isEmpty)
        XCTAssertTrue(mockLogger2.logMessage.isEmpty)

        logNDT7("test log level")
        logNDT7("test info log level", .info)
        logNDT7("test info log level", .info)
        logNDT7("test error log level", .error)

        XCTAssertEqual(mockLogger1.logMessage.count, 4)
        XCTAssertEqual(mockLogger2.logMessage.count, 4)
        XCTAssertTrue(mockLogger1.logMessage.contains(where: { $0.text == "test log level" }))
        XCTAssertTrue(mockLogger2.logMessage.contains(where: { $0.text == "test log level" }))
        XCTAssertTrue(mockLogger1.logMessage.contains(where: { $0.text == "test info log level" }))
        XCTAssertTrue(mockLogger2.logMessage.contains(where: { $0.text == "test info log level" }))
        XCTAssertTrue(mockLogger1.logMessage.contains(where: { $0.text == "test warning log level" }) == false)
        XCTAssertTrue(mockLogger2.logMessage.contains(where: { $0.text == "test warning log level" }) == false)
        XCTAssertTrue(mockLogger1.logMessage.contains(where: { $0.text == "test error log level" }))
        XCTAssertTrue(mockLogger2.logMessage.contains(where: { $0.text == "test error log level" }))
    }
}
