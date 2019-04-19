//
//  WeakRefTests.swift
//  NDT7
//
//  Created by Miguel on 4/19/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class WeakRefTests: XCTestCase {

    func testWeakRef() {
        var ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        var weakRef = [WeakRef<NDT7Test>]()
        weakRef.append(WeakRef(ndt7Test))
        XCTAssertEqual(weakRef.count, 1)
        XCTAssertTrue(weakRef.first?.object! === ndt7Test!)
        ndt7Test = nil
        XCTAssertEqual(weakRef.count, 1)
        XCTAssertNotNil(weakRef.first)
        XCTAssertNil(weakRef.first?.object)
    }
}
