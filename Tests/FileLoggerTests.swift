//
//  FileLoggerTests.swift
//  NDT7
//
//  Created by Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class FileLoggerTests: XCTestCase {

    let fileManager = FileManager.default
    let path = "test.log"

    override func setUp() {
        fileManager.createFile(atPath: path, contents: "".data(using: .utf8), attributes: nil)
    }

    override func tearDown() {
        do {
            try fileManager.removeItem(atPath: path)
            let fileLogger = FileLogger(path: path)
            XCTAssertNil(fileLogger)
        } catch {
            XCTFail("File not removed")
        }
        XCTAssertTrue(fileManager.fileExists(atPath: path) == false)
    }

    func testFileLogger() {

        XCTAssertTrue(fileManager.fileExists(atPath: path))

        if let fileLogger = FileLogger(path: path) {

            fileLogger.addLogMessage(LogMessage(text: "test 0", level: .info, file: #file, function: #function, line: #line))
            fileLogger.addLogMessage(LogMessage(text: "test 1", level: .info, file: "fileName 1", function: "functionName 1", line: 10))
            fileLogger.addLogMessage(LogMessage(text: "test 2", level: .debug, file: "fileName 2", function: "functionName 2", line: 22))
            fileLogger.addLogMessage(LogMessage(text: "test 3", level: .warning, file: "fileName 3", function: "functionName 3", line: 23))
            fileLogger.addLogMessage(LogMessage(text: "test 4", level: .error, file: "fileName 4", function: "functionName 4", line: 49))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [FileLoggerTests.swift-testFileLogger():38]: (info) test 0\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 1-functionName 1:10]: (info) test 1\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 2-functionName 2:22]: (debug) test 2\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 3-functionName 3:23]: (warning) test 3\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 4-functionName 4:49]: (error) test 4\n"))

            fileLogger.addLogMessage(LogMessage(text: "test 5", level: .error, file: "fileName 5", function: "functionName 5", line: 45))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 1-functionName 1:10]: (info) test 1\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 2-functionName 2:22]: (debug) test 2\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 3-functionName 3:23]: (warning) test 3\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 4-functionName 4:49]: (error) test 4\n"))
            XCTAssertTrue(fileLogger.readLogFile()!.contains("[ndt7] [com.apple.main-thread] [fileName 5-functionName 5:45]: (error) test 5\n"))
        } else {
            XCTFail("FileLogger not created with path: \(path)")
        }
    }

    func testWrongPathFileLogger() {

        let wrongPath = "wrongPath.log"
        XCTAssertTrue(!fileManager.fileExists(atPath: wrongPath))
        if FileLogger(path: wrongPath) == nil {
            let fileLogger = FileLogger(path: wrongPath)
            fileLogger?.addLogMessage(LogMessage(text: "test 0", level: .info, file: #file, function: #function, line: #line))
            XCTAssertNil(fileLogger?.readLogFile())
        } else {
            XCTFail("FileLogger not created with path: \(path)")
        }
    }
}
