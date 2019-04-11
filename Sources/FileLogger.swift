//
//  FileLogger.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/10/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Save log messages to a log file and read the file.
class FileLogger: Logger {

    private let fileHandle: FileHandle
    private let path: String

    init?(path: String) {

        guard let fileHandle = FileHandle(forWritingAtPath: path) else {
            return nil
        }
        self.fileHandle = fileHandle
        self.fileHandle.seekToEndOfFile()
        self.path = path
    }

    deinit {
        fileHandle.closeFile()
    }

    /// Add a log message to the log file.
    /// - parameter logMessage: The message to be added.
    func addLogMessage(_ logMessage: LogMessage) {

        if let data = "\(logMessage.ndt7Description())\n".data(using: .utf8) {
            fileHandle.write(data)
        }
    }

    /// Read the log file.
    /// - returns: All the messages in the log file.
    func readLogFile() -> String? {

        guard let fileHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        let data = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()
        return String(data: data, encoding: .utf8)
    }
}
