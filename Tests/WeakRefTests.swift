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

    func testWeakRefNil() {
        let weakRef = WeakRef<NDT7Test>()
        XCTAssertNil(weakRef.object)
    }

    func testWeakRef() {
        var ndt7Test: NDT7Test? = NDT7Test(settings: NDT7Settings())
        var weakRef = [WeakRef<NDT7Test>]()
        var weakRefNDT7Test = WeakRef(ndt7Test)
        weakRefNDT7Test.object = ndt7Test
        weakRef.append(weakRefNDT7Test)
        XCTAssertEqual(weakRef.count, 1)
        XCTAssertTrue(weakRef.first?.object! === ndt7Test!)
        var weakRefNDT7TestDescription = weakRefNDT7Test.description
        XCTAssertEqual(weakRefNDT7TestDescription, "Weak(NDT7.NDT7Test)")
        ndt7Test = nil
        weakRefNDT7TestDescription = weakRefNDT7Test.description
        XCTAssertEqual(weakRefNDT7TestDescription, "nil")
        XCTAssertEqual(weakRef.count, 1)
        XCTAssertNotNil(weakRef.first)
        XCTAssertNil(weakRef.first?.object)
    }
}
