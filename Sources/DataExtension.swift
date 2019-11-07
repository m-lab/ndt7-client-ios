//
//  DataExtension.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 5/16/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Data Extension.
extension Data {

    /// Provides a random 8192 bytes data object.
    /// - returns: 8192 bytes data object based in random UInt8 objects.
    static func randomDataNetworkElement() -> Data {
        let dataArray: [UInt8] = (0..<(NDT7WebSocketConstants.Request.bulkMessageSize)).map { _ in
            UInt8.random(in: 1...255)
        }
        return dataArray.withUnsafeBufferPointer { Data(buffer: $0) }
    }
}
