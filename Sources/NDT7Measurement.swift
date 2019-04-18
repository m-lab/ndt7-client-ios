//
//  NDT7Measurement.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/17/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// For measurement, the server and client exchange JSON measurements using Textual WebSocket messages.
/// NDT7Measurement represents such JSON measurements, which contains all the information.
///
/// Example:
/// ```
/// {
///  "app_info": {
///    "num_bytes": 17,
///  },
///  "bbr_info": {
///    "max_bandwidth": 12345,
///    "min_rtt": 123.4
///  },
///  "elapsed": 1.2345,
///  "tcp_info": {
///    "rtt_var": 123.4,
///    "smoothed_rtt": 567.8
///  }
/// }
/// ```
///
public struct NDT7Measurement: Codable, CustomStringConvertible {

    /// elapsed (a float64) is the number of seconds elapsed since the beginning of the specific subtest and marks
    /// the moment in which the measurement has been performed by the client or by the server.
    public let elapsed: Float64?

    /// tcpInfo is an optional object only included in the measurement when it is possible to access TCP_INFO stats.
    public let tcpInfo: NDT7TCPInfo?

    /// appInfo is an optional object only included in the measurement when an application-level measurement is available.
    public let appInfo: NDT7APPInfo?

    /// bbrInfo is an optional object only included in the measurement when it is possible to access TCP_CC_INFO stats for BBR.
    public let bbrInfo: NDT7BBRInfo?

    /// coding keys for codable purpose.
    public enum CodingKeys: String, CodingKey {
        case elapsed = "elapsed"
        case tcpInfo = "tcp_info"
        case appInfo = "app_info"
        case bbrInfo = "bbr_info"
    }

    /// description contains a formated string for NDT7Measurement.
    public var description: String {
        let elapsedString = elapsed != nil ? String(elapsed!) : "-"
        let tcpInfoString = tcpInfo != nil ? String(describing: tcpInfo!) : "-"
        let appInfoString = appInfo != nil ? String(describing: appInfo!) : "-"
        let bbrInfoString = bbrInfo != nil ? String(describing: bbrInfo!) : "-"
        return "elapsed: \(elapsedString), TCP info: \"\(tcpInfoString)\", APP info: \"\(appInfoString)\", BBR info: \"\(bbrInfoString)\""
    }
}

/// NDT7TCPInfo is an optional object only included in the measurement when it is possible to access TCP_INFO stats.
public struct NDT7TCPInfo: Codable, CustomStringConvertible {

    /// smoothedRtt (a float64) is the smoothed RTT in milliseconds.
    public let smoothedRtt: Float64?

    /// rttVar (a float64) is RTT variance in milliseconds;
    public let rttVar: Float64?

    /// coding keys for codable purpose.
    public enum CodingKeys: String, CodingKey {
        case smoothedRtt = "smoothed_rtt"
        case rttVar = "rtt_var"
    }

    /// description contains a formated string for NDT7TCPInfo.
    public var description: String {
        let smoothedRttString = smoothedRtt != nil ? String(smoothedRtt!) : "-"
        let rttVarString = rttVar != nil ? String(describing: rttVar!) : "-"
        return "smoothed RTT: \(smoothedRttString), RTT var: \(rttVarString)"
    }
}

/// NDT7APPInfo is an optional object only included in the measurement when an application-level measurement is available.
public struct NDT7APPInfo: Codable, CustomStringConvertible {

    /// numBytes (a int64) is the number of bytes sent (or received) since the beginning of the specific subtest.
    /// Note that this counter tracks the amount of data sent at application level.
    /// It does not account for the protocol overheaded of WebSockets, TLS, TCP, IP, and link layer.
    public let numBytes: Int64?

    /// coding keys for codable purpose.
    public enum CodingKeys: String, CodingKey {
        case numBytes = "num_bytes"
    }

    /// description contains a formated string for NDT7APPInfo.
    public var description: String {
        let numBytesString = numBytes != nil ? String(numBytes!) : "-"
        return "num bytes: \(numBytesString)"
    }
}

/// NDT7BBRInfo is an optional object only included in the measurement when it is possible to access TCP_CC_INFO stats for BBR.
public struct NDT7BBRInfo: Codable, CustomStringConvertible {

    /// bandwith (a int64) is the max-bandwidth measured by BBR, in bits per second.
    public let bandwith: Int64?

    /// minRtt (a float64) is the min-rtt measured by BBR, in millisecond;
    public let minRtt: Float64?

    /// coding keys for codable purpose.
    public enum CodingKeys: String, CodingKey {
        case bandwith = "max_bandwidth"
        case minRtt = "min_rtt"
    }

    /// description contains a formated string for NDT7BBRInfo.
    public var description: String {
        let bandwithString = bandwith != nil ? String(bandwith!) : "-"
        let minRttString = minRtt != nil ? String(describing: minRtt!) : "-"
        return "bandwith: \(bandwithString), min RTT: \(minRttString)"
    }
}
