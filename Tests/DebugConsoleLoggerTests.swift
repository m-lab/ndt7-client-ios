//
//  DebugConsoleLoggerTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class DebugConsoleLoggerTests: XCTestCase {

    func testDebugConsoleLogger() {
        let debugConsole = DebugConsoleLogger()
        let logMessage = LogMessage(text: "text",
                                    level: .debug,
                                    file: #file,
                                    function: #function,
                                    line: #line)
        debugConsole.addLogMessage(logMessage)
    }
}
