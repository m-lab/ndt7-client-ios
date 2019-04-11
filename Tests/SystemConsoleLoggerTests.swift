//
//  SystemConsoleLoggerTests.swift
//  NDT7
//
//  Created by Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class SystemConsoleLoggerTests: XCTestCase {

    func testOsLogLevel() {

        let systemConsoleLogger = SystemConsoleLogger()

        XCTAssertEqual(systemConsoleLogger.osLogLevel(.info), .info)
        XCTAssertEqual(systemConsoleLogger.osLogLevel(.debug), .debug)
        XCTAssertEqual(systemConsoleLogger.osLogLevel(.warning), .error)
        XCTAssertEqual(systemConsoleLogger.osLogLevel(.error), .fault)
    }
}
