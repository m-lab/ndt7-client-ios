//
//  QueueTests.swift
//  NDT7
//
//  Created by Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class QueueTests: XCTestCase {

    func testMainQueueName() {
        let expectationMain = XCTestExpectation(description: "Job in main thread")
        DispatchQueue.main.async {
            let queueNameString = queueName()
            XCTAssertEqual(queueNameString, "Operation queue: com.apple.main-thread-thread")
            expectationMain.fulfill()
        }
        wait(for: [expectationMain], timeout: 5.0)
    }

    func testBackgroundQueueNameWithLabel() {
        let expectationLabel = XCTestExpectation(description: "Job in background thread")
        let dispatchQueue = DispatchQueue(label: "com.ndt7.queueTest")
        dispatchQueue.async {
            let queueNameString = queueName()
            XCTAssertEqual(queueNameString, "Dispatch queue: com.ndt7.queueTest-thread")
            expectationLabel.fulfill()
        }
        wait(for: [expectationLabel], timeout: 5.0)
    }

    func testBackgroundQueueNameWithNoLabel() {
        let expectationNoLabel = XCTestExpectation(description: "Job in background thread with no label")
        DispatchQueue.global().async {
            let queueNameString = queueName()
            XCTAssertTrue(queueNameString!.contains("com.apple.root.default"))
            expectationNoLabel.fulfill()
        }
        wait(for: [expectationNoLabel], timeout: 5.0)
    }
}
