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
    
    if let currentOperationQueueLabel = OperationQueue.current?.underlyingQueue?.label {
        return currentOperationQueueLabel
    } else {
        let currentQueueLabel = __dispatch_queue_get_label(nil)
        return String(cString: currentQueueLabel, encoding: .utf8)
    }
}
