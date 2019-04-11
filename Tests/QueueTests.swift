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

    func testQueueName() {
        
        // Test for main Queue
        let expectationMain = XCTestExpectation(description: "Job in main thread")
        DispatchQueue.main.async {
            let queueNameString = queueName()
            XCTAssertEqual(queueNameString, "com.apple.main-thread")
            expectationMain.fulfill()
        }
        wait(for: [expectationMain], timeout: 5.0)
        
        // Test for background queue with label
        let expectationLabel = XCTestExpectation(description: "Job in background thread")
        let dispatchQueue = DispatchQueue(label: "com.ndt7.queueTest")
        dispatchQueue.async {
            let queueNameString = queueName()
            XCTAssertEqual(queueNameString, "com.ndt7.queueTest")
            expectationLabel.fulfill()
        }
        wait(for: [expectationLabel], timeout: 5.0)
        
        // Test for background queue with no label
        let expectationNoLabel = XCTestExpectation(description: "Job in background thread with no label")
        DispatchQueue.global().async {
            let queueNameString = queueName()
            XCTAssertTrue(queueNameString!.contains("com.apple.root.default"))
            expectationNoLabel.fulfill()
        }
        wait(for: [expectationNoLabel], timeout: 5.0)
    }
}
