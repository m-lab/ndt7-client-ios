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
/// Note that the JSON exchanged on the wire, MAY possibly contain more TCP_INFO fields.
/// Yet, only the fields described in this specification are returned by a compliant,
/// TCP_INFO enabled implementation of ndt7.
///
/// Example of JSON to be matched with NDT7Measurement object v0.8.3 of the specification:
///
/// ```
/// {
///  "AppInfo": {
///    "ElapsedTime": 1234,
///    "NumBytes": 1234,
///  },
///  "ConnectionInfo": {
///    "Client": "1.2.3.4:5678",
///    "Server": "[::1]:2345",
///    "UUID": "<platform-specific-string>"
///  },
///  "Origin": "server",
///  "Test": "download",
///  "TCPInfo": {
///    "BusyTime": 1234,
///    "BytesAcked": 1234,
///    "BytesReceived": 1234,
///    "BytesSent": 1234,
///    "BytesRetrans": 1234,
///    "ElapsedTime": 1234,
///    "MinRTT": 1234,
///    "RTT": 1234,
///    "RTTVar": 1234,
///    "RWndLimited": 1234,
///    "SndBufLimited": 1234
///  }
/// }
/// ```
///
public struct NDT7Measurement: Codable {

    /// appInfo is an optional object that contains application level measurement.
    public var appInfo: NDT7APPInfo?

    /// bbrInfo is an optional object that contains the data measured using TCP BBR instrumentation.
    public var bbrInfo: NDT7BBRInfo?

    /// connectionInfo is an optional object used to provide information about the connection.
    /// Servers send this message exactly once.
    public var connectionInfo: NDT7ConnectionInfo?

    /// origin is an optional string that indicates whether the measurement has been performed by the client or by the server. ie client or server
    public var origin: NDT7TestConstants.Origin?

    /// direction is an optional string that indicates the name of the current test. ie. download or upload
    public var direction: NDT7TestConstants.Kind?

    /// tcpInfo is an optional object that contains a TCP_INFO measurement.
    public let tcpInfo: NDT7TCPInfo?

    /// rawData is an optional object that contains the json measurement.
    /// It can contains more information about the current measurement.
    public var rawData: String?

    /// coding keys for codable purpose.
    enum CodingKeys: String, CodingKey {
        case appInfo = "AppInfo"
        case bbrInfo = "BBRInfo"
        case connectionInfo = "ConnectionInfo"
        case origin = "Origin"
        case direction = "Test"
        case tcpInfo = "TCPInfo"
        case rawData = "rawData"
    }
}

/// NDT7APPInfo is an optional object only included in the measurement when an application-level measurement is available.
public struct NDT7APPInfo: Codable {

    /// elapsed (an Int64) is the time elapsed since the beginning of this test, measured in microseconds.
    public let elapsedTime: Int64?

    /// numBytes (an Int64) is the number of bytes sent (or received) since the beginning of the specific test.
    /// Note that this counter tracks the amount of data sent at application level.
    /// It does not account for the protocol overheaded of the WebSockets, TLS, TCP/IP, and link layers.
    public var numBytes: Int64?

    /// coding keys for codable purpose.
    enum CodingKeys: String, CodingKey {
        case elapsedTime = "ElapsedTime"
        case numBytes = "NumBytes"
    }
}

/// NDT7BBRInfo is an optional object only included in the measurement when it is possible to access TCP_CC_INFO stats for BBR.
public struct NDT7BBRInfo: Codable {

    /// elapsedTime (an Int64) is the time elapsed since the beginning of this test, measured in microseconds.
    public let elapsedTime: Int64?

    /// bandwith (a Int64) is the max-bandwidth measured by BBR, in bits per second.
    public let bandwith: Int64?

    /// minRtt (a Int64) is the min-rtt measured by BBR, in millisecond;
    public let minRtt: Int64?

    /// Pacing gain shifted left 8 bits
    public let pacingGain: Int64?

    /// Cwnd gain shifted left 8 bits
    public let cwndGain: Int64?

    /// coding keys for codable purpose.
    enum CodingKeys: String, CodingKey {
        case elapsedTime = "ElapsedTime"
        case bandwith = "BW"
        case minRtt = "MinRTT"
        case pacingGain = "PacingGain"
        case cwndGain = "CwndGain"
    }
}

/// NDT7ConnectionInfo is an optional object used to provide information about the connection four tuple.
/// Clients MUST NOT send this message. Servers MUST send this message exactly once.
/// Clients SHOULD cache the first received instance of this message, and discard any subsequently received instance of this message.
public struct NDT7ConnectionInfo: Codable {

    /// client (a string), which contains the serialization of the client endpoint according to the server.
    /// Note that the general format of this field is <address>:<port> where IPv4 addresses are provided verbatim,
    /// while IPv6 addresses are quoted by [ and ] as shown in the above example: [::1]:2345
    public let client: String?

    /// server (a string), which contains the serialization of the server endpoint according to the server,
    /// following the same general format specified above for the Client field.
    /// i.e. ndt-8v44h_1565994790_0000000000030E8F.
    public let server: String?

    /// uuid (a string), which contains an internal unique identifier for this test within the Measurement Lab (M-Lab) platform.
    public let uuid: String?

    /// coding keys for codable purpose.
    enum CodingKeys: String, CodingKey {
        case client = "Client"
        case server = "Server"
        case uuid = "UUID"
    }
}

/// NDT7TCPInfo is an optional object only included in the measurement when it is possible to access TCP_INFO stats.
///
/// The MinRTT, RTT, and RTTVar fields can be used to compute the statistics of the round-trip time.
/// The buildup of a large queue is unexpected when using BBR.
/// It generally indicates the presence of a bottleneck with a large buffer that's filling as the test proceeds.
/// The MinRTT can also be useful to verify we're using a reasonably nearby-server.
/// Also, an unreasonably small RTT when the link is 2G or 3G could indicate a performance enhancing proxy.
///
/// The times (BusyTime, RWndLimited, and SndBufLimited) are useful to understand where the bottleneck could be.
/// In general we would like to see that we've been busy for most of the test runtime.
/// If RWndLimited is large, then it means that the receiver does not have enough buffering to go faster and it is limiting our performance.
/// Likewise, when SndBufLimited is large, the sender's buffer is too small.
/// Also, if adding up these three times gives us less time than the duration of the test,
/// it generally means that the sender was not filling the send buffer fast enough for keeping TCP busy,
/// thus slowing us down.
///
/// The amount of BytesAcked combined with the ElapsedTime gives us the average speed at which we've been sending, measured in the kernel.
/// Because of the measurement unit used, by default the speed will be in bytes per microsecond.
/// Typically the speed of file transfers is measured instead in bytes per second, so you need to multiply by 10^6.
/// To obtain the speed in bits per second, which is the typical unit with which we measure the speed of links (e.g. Wi-Fi), also multiply by 8.
///
/// BytesReceived is just like BytesAcked, except that BytesAcked makes sense for the sender
/// (e.g. the server during the download), while BytesReceived makes sense for the receiver (e.g. the server during the upload).
///
/// BytesSent and BytesRetrans can be used to compute the percentage of bytes overall that have been retransmitted.
/// In turn, this is value approximates the packet loss rate, i.e. the (unknown) probability with which the network is likely to drop a packet.
/// This approximation is really bad because it assumes that the probability of dropping a packet is uniformly distributed,
/// which isn't likely the case. Yet, it may be an useful first order information to characterise a network as possibly very lossy.
/// Some packet loss is normal and healthy,
/// but too much packet loss is the sign of a network path with systemic problems.
public struct NDT7TCPInfo: Codable {

    /// busyTime aka tcpi_busy_time (an optional Int64),
    /// i.e. the number of microseconds spent actively sending data because the write queue of the TCP socket is non-empty.
    public let busyTime: Int64?

    /// bytesAcked aka tcpi_bytes_acked (an optional Int64),
    /// i.e. the number of bytes for which we received acknowledgment.
    /// Note that this field, and all other TCPInfo fields, contain the number of bytes measured at TCP/IP level
    /// (i.e. including the WebSocket and TLS overhead).
    public let bytesAcked: Int64?

    /// bytesReceived aka tcpi_bytes_received (an optional Int64),
    /// i.e. the number of bytes for which we sent acknowledgment.
    public let bytesReceived: Int64?

    /// bytesSent aka tcpi_bytes_sent (an optional Int64),
    /// i.e. the number of bytes which have been transmitted or retransmitted.
    public let bytesSent: Int64?

    /// bytesRetrans aka tcpi_bytes_retrans (an optional Int64),
    /// i.e. the number of bytes which have been retransmitted.
    public let bytesRetrans: Int64?

    /// elapsedTime (an optional Int64),
    /// this field indicates the moment in which TCP_INFO data has been generated, and therefore is generally useful.
    /// i.e. the time elapsed since the beginning of this test, measured in microseconds.
    public let elapsedTime: Int64?

    /// minRTT aka tcpi_min_rtt (an optional Int64),
    /// i.e. the minimum RTT seen by the kernel, measured in microseconds.
    public let minRTT: Int64?

    /// rtt aka tcpi_rtt (an optional Int64), i.e. the current smoothed RTT value, measured in microseconds.
    public let rtt: Int64?

    /// rttVar aka tcpi_rtt_var (an optional Int64), i.e. the variance or RTT.
    public let rttVar: Int64?

    /// rwndLimited aka tcpi_rwnd_limited (an optional Int64),
    /// i.e. the amount of microseconds spent stalled because there is not enough buffer at the receiver.
    public let rwndLimited: Int64?

    /// sndBufLimited aka tcpi_sndbuf_limited (an optional Int64),
    /// i.e. the amount of microseconds spent stalled because there is not enough buffer at the sender.
    public let sndBufLimited: Int64?

    /// coding keys for codable purpose.
    enum CodingKeys: String, CodingKey {
        case busyTime = "BusyTime"
        case bytesAcked = "BytesAcked"
        case bytesReceived = "BytesReceived"
        case bytesSent = "BytesSent"
        case bytesRetrans = "BytesRetrans"
        case elapsedTime = "ElapsedTime"
        case minRTT = "MinRTT"
        case rtt = "RTT"
        case rttVar = "RTTVar"
        case rwndLimited = "RWndLimited"
        case sndBufLimited = "SndBufLimited"
    }
}
