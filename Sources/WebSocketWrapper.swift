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
    var webSocket: WebSocket?
    let url: URL
    let settings: NDT7Settings
    var outputBytesLengthAccumulated: Int {
        return webSocket?.ws.outputBytesLengthAccumulated ?? 0
    }
    var inputBytesLengthAccumulated: Int {
        return webSocket?.ws.inputBytesLengthAccumulated ?? 0
    }
    let dispatchQueue = DispatchQueue.init(label: "net.measurementlab.NDT7.read.URLSessionWebSocketTask")

    init?(settings: NDT7Settings, url: URL) {
        self.url = url
        self.settings = settings
        var urlRequest = URLRequest(url: self.url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: settings.timeout.ioTimeout)
        for (header, value) in settings.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        webSocket = WebSocket(request: urlRequest)
        webSocket?.allowSelfSignedSSL = settings.skipTLSCertificateVerification
        webSocket?.delegate = self
    }

    deinit {
        webSocket?.delegate = nil
        webSocket?.close()
    }
}

extension WebSocketWrapper {

    func open(_ interval: TimeInterval = 0.5, _ maxRetries: UInt = 10) {
        logNDT7("WebSocket \(url.absoluteString) opening. Max retries: \(maxRetries)")
        if !open {
            open = true
            webSocket?.open()
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
        webSocket?.close()
    }

    func send(_ message: Any, maxBuffer: Int) -> Int? {
        guard let buffer = webSocket?.ws.outputBytesLength, buffer < maxBuffer else { return nil }
        if open {
            webSocket?.send(message, NDT7WebSocketConstants.Request.maxConcurrentMessages)
            return buffer
        } else {
            logNDT7("WebSocket \(url.absoluteString) did not send message. WebSocket not connected")
            return nil
        }
    }
}

extension WebSocketWrapper: WebSocketDelegate {

    func webSocketOpen() {
        logNDT7("WebSocket \(url.absoluteString) open")
        open = true
        delegate?.open(webSocket: self)
        webSocket?.ws.outputBytesLengthAccumulated = 0
        webSocket?.ws.inputBytesLengthAccumulated = 0
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
        connected = true
        delegate?.message(webSocket: self, message: text)
    }

    func webSocketMessageData(_ data: Data) {
        connected = true
        delegate?.message(webSocket: self, message: data)
    }
}
