//
//  NDT7Tests.swift
//  NDT7Tests
//
//  Created by Miguel on 3/29/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class NDT7Tests: XCTestCase {

    class MockLogger: Logger {

        var logMessage: [LogMessage] = []

        func addLogMessage(_ logMessage: LogMessage) {
            self.logMessage.append(logMessage)
        }
    }

    var mockLogger: MockLogger!

    override func setUp() {
        mockLogger = MockLogger()
        NDT7.loggingEnabled = false
    }

    override func tearDown() {
        NDT7.loggingEnabled = false
    }

    func testNDT7EnableAndDisableLogging() {

        LogManager.addLogger(mockLogger)
        XCTAssertFalse(NDT7.loggingEnabled)
        XCTAssertEqual(mockLogger.logMessage.count, 0)

        NDT7.loggingEnabled = true
        XCTAssertTrue(NDT7.loggingEnabled)

        logNDT7("test")
        logNDT7("test", .debug)
        logNDT7("test", .warning)
        logNDT7("test", .error)
        XCTAssertEqual(mockLogger.logMessage.count, 5)

        NDT7.loggingEnabled = false
        XCTAssertFalse(NDT7.loggingEnabled)

        logNDT7("test")
        XCTAssertEqual(mockLogger.logMessage.count, 6)
    }
}
