//
//  Constants.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/22/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Websocket constants definition.
public struct NDT7Constants {

    /// Test cancelled.
    public static let domain = "net.measurementlab.NDT7"

    public struct MlabServerDiscover {

        /// Discover closer server hostname url.
        public static let hostname = "locate-dot-mlab-staging.appspot.com"

        /// Discover server path.
        public static let path = "ndt_ssl"

        /// Geo options.
        public static let geoOption = "geo_options"

        /// Discover list of Mlab Servers with Geo Options
        public static let urlWithGeoOption = "https://\(hostname)/\(path)?policy=\(geoOption)"

        /// Discover closer Mlab Server
        public static let url = "https://\(hostname)/\(path)"

        /// Cannot find a suitable mlab server error
        public static let noMlabServerError = NSError(domain: NDT7Constants.domain,
                                                        code: 0,
                                                        userInfo: [ NSLocalizedDescriptionKey: "Cannot find a suitable mlab server"])
    }

    /// Websocket constants definition.
    public struct WebSocket {

        /// Hostname.
        public static let hostname = "ndt-iupui-mlab4-lax04.measurement-lab.org"

        /// Download Path.
        public static let downloadPath = "/ndt/v7/download"

        /// Upload Path.
        public static let uploadPath = "/ndt/v7/upload"

        /// protocol key header.
        public static let headerProtocolKey = "Sec-WebSocket-Protocol"

        /// protocol value header.
        public static let headerProtocolValue = "net.measurementlab.ndt.v7"

        /// Accept key header.
        public static let headerAcceptKey = "Sec-WebSocket-Accept"

        /// Accept value header.
        public static let headerAcceptValue = "Nhz+x95YebD6Uvd4nqPC2fomoUQ="

        /// Version key header.
        public static let headerVersionKey = "Sec-WebSocket-Version"

        /// Version value header.
        public static let headerVersionValue = "13"

        /// WebSocket key header.
        public static let headerKey = "Sec-WebSocket-Key"

        /// WebSocket value header.
        public static let headerValue = "DOdm+5/Cm3WwvhfcAlhJoQ=="
    }

    /// Test Constants.
    public struct Test {

        /// Test cancelled.
        public static let cancelled = "Test cancelled"
    }
}
