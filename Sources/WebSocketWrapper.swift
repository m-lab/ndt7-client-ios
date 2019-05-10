//
//  WebSocketWrapper.swift
//  NDT7
//
//  Created by NietoGuillen, Miguel on 4/15/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import Foundation

/// Protocol to allow websocket interaction.
protocol WebSocketInteraction: class {
    func open(webSocket: WebSocketWrapper)
    func close(webSocket: WebSocketWrapper)
    func message(webSocket: WebSocketWrapper, message: Any)
    func error(webSocket: WebSocketWrapper, error: NSError)
}

/// WebSocket wrapper.
class WebSocketWrapper {

    weak var delegate: WebSocketInteraction?
    var open = false
    var connected = false
    let webSocket: WebSocket
    let url: URL
    let settings: NDT7Settings

    init?(settings: NDT7Settings, url: URL) {
        self.url = url
        self.settings = settings
        var urlRequest = URLRequest(url: self.url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: settings.timeout.request)
        for (header, value) in settings.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        webSocket = WebSocket(request: urlRequest)
        webSocket.allowSelfSignedSSL = settings.skipTLSCertificateVerification
        webSocket.delegate = self
    }

    deinit {
        webSocket.delegate = nil
        webSocket.close()
    }
}

extension WebSocketWrapper {

    func open(_ interval: TimeInterval = 0.5, _ maxRetries: UInt = 10) {
        logNDT7("WebSocket \(url.absoluteString) opening. Max retries: \(maxRetries)")
        if !open {
            open = true
            webSocket.open()
        }
        if maxRetries > 0 && !connected {
            // If the connection is closed retry to open it.
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.open(interval, maxRetries - 1)
            }
        }
    }

    func close() {
        logNDT7("WebSocket \(url.absoluteString) closing")
        webSocket.close()
    }

    func send(_ message: Any) {
//        if open && connected {
        if open {
            DispatchQueue.global().async { [weak self] in
                for _ in 1...100 {
                    //            for _ in 0...50000000 {
                    print("miguel test date start: \(Date())")
                    //                print("miguel test 1: \(webSocket.ws.outputBytes)")
                    //                print("miguel test 2: \(webSocket.ws.outputBytesSize)") // should be the windowBufferSize: 8192
                    //                print("miguel test 3: \(webSocket.ws.outputBytesStart)")
                    //                print("miguel test 4: \(webSocket.ws.outputBytesLength)")
                    print("outputBytesLength send message: \(message)")
                    self?.webSocket.send(message)
                    print("miguel test date end: \(Date())")
                    print("miguel angel \(self?.webSocket.ws.wr.hasSpaceAvailable) - \(self?.webSocket.ws.wr.debugDescription))")
                    print("miguel test 5: \(self?.webSocket.ws.outputBytes)")
                                    print("miguel test 6: \(self?.webSocket.ws.outputBytesSize)") // should be the windowBufferSize: 8192
                                    print("miguel test 7: \(self?.webSocket.ws.outputBytesStart)")
                                    print("miguel test 8: \(self?.webSocket.ws.outputBytesLength) - \(Date())")
                    logNDT7("WebSocket \(self?.url.absoluteString) did send message")
//                    if self?.webSocket.ws.wr.hasSpaceAvailable {
//                        print("miguel space: 1")
//                    } else {
//                        print("miguel space: 2")
//                    }
                }
            }
            
        } else {
            logNDT7("WebSocket \(url.absoluteString) did not send message. WebSocket not connected")
        }
    }
}

extension WebSocketWrapper: WebSocketDelegate {

    func webSocketOpen() {
        logNDT7("WebSocket \(url.absoluteString) open")
        open = true
        delegate?.open(webSocket: self)
    }

    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        logNDT7("WebSocket \(url.absoluteString) closed")
        open = false
        connected = false
        delegate?.close(webSocket: self)
    }

    func webSocketError(_ error: NSError) {
        logNDT7("WebSocket \(url.absoluteString) did get error: \(error.localizedDescription)", .error)
        delegate?.error(webSocket: self, error: error)
    }

    func webSocketMessageText(_ text: String) {
        logNDT7("WebSocket \(url.absoluteString) did get message text")
        connected = true
        delegate?.message(webSocket: self, message: text)
    }

    func webSocketMessageData(_ data: Data) {
        logNDT7("WebSocket \(url.absoluteString) did get message data \(data)")
        connected = true
        delegate?.message(webSocket: self, message: data)
    }
}
