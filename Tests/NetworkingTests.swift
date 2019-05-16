//
//  NetworkingTests.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 5/16/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import XCTest
@testable import NDT7

class NetworkingTests: XCTestCase {

    func testURLRequest() {
        let requestDownload = Networking.urlRequest("https://ndt-iupui-mlab4-lax04.measurement-lab.org/ndt/v7/download")
        XCTAssertEqual(requestDownload.url?.absoluteString, "https://ndt-iupui-mlab4-lax04.measurement-lab.org/ndt/v7/download")
        let requestUpload = Networking.urlRequest("https://ndt-iupui-mlab4-lax04.measurement-lab.org/ndt/v7/upload")
        XCTAssertEqual(requestUpload.url?.absoluteString, "https://ndt-iupui-mlab4-lax04.measurement-lab.org/ndt/v7/upload")
    }
}
