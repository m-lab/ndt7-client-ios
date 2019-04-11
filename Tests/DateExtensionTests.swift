//
//  DateExtensionTests.swift
//  NDT7
//
//  Created by Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class DateExtensionTests: XCTestCase {

    func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }

    func testLogStringDateFormat() {
        let date = makeDate(year: 1977, month: 3, day: 14, hr: 4, min: 28, sec: 35)
        let logStringDateFormate = date.toString()
        XCTAssertTrue(logStringDateFormate.contains("1977-03-14 04:28:35"))
        XCTAssertEqual(logStringDateFormate.count, 31)
    }
}
