//
//  Queue.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/9/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Returns the current queue name.
/// - returns: queue name.
func queueName() -> String? {
    if let operationQueue = OperationQueue.current {
        if let dispatchQueue = operationQueue.underlyingQueue {
            return "Operation queue: \(!dispatchQueue.label.isEmpty ? dispatchQueue.label : dispatchQueue.description)-thread"
        } else {
            return "Operation queue: \(operationQueue.name != nil ? operationQueue.name! : operationQueue.description)-thread"
        }
    } else {
        let currentThread = Thread.current
        let currentQueueLabel = __dispatch_queue_get_label(nil)
        let unknown = "Unknown queue \(currentThread.name != nil ? currentThread.name! : currentThread.description)"
        return "Dispatch queue: \(String(cString: currentQueueLabel, encoding: .utf8) ?? unknown)-thread"
    }
}
