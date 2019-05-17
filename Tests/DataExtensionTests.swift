//
//  DataExtensionTests.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 5/16/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class DataExtensionTests: XCTestCase {

    func testRandomDataNetworkElement() {
        let dataElement = Data.randomDataNetworkElement()
        XCTAssertEqual(dataElement.count, 8192)
    }
}
