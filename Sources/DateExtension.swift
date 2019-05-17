//
//  DateExtension.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/8/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Date Extension.
extension Date {

    /// Date and time format for log message.
    static let logStringDateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"

    /// DateFormatter for log message.
    static let logDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = logStringDateFormat
        return dateFormatter
    }()

    /// Convert date to string using specific date format.
    /// - parameter dateFormatter: date format as DateFormatter. Default: DateFormatter for log message.
    /// - returns: string with specific format.
    func toString(dateFormatter: DateFormatter = Date.logDateFormatter) -> String {
        return dateFormatter.string(from: self)
    }
}
