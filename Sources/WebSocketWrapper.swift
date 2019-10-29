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
class WebSocketWrapper: NSObject {

    weak var delegate: WebSocketInteraction?
    var open = false
    var connected = false
    let webSocket: WebSocket?
    let url: URL
    let settings: NDT7Settings
    var outputBytesLengthAccumulated: Int {
        if webSocketTask != nil {
            return dataCountSent
        } else {
            return webSocket?.ws.outputBytesLengthAccumulated ?? 0
        }
    }
    var inputBytesLengthAccumulated: Int {
        if webSocketTask != nil {
            return dataCountReceived
        } else {
            return webSocket?.ws.inputBytesLengthAccumulated ?? 0
        }
    }

    /// WebSocket via URLSessionWebSocketTask
    var enableiOS13Socket = false
    var webSocketTask: Any?
    var dataCountSent = 0
    var dataCountReceived = 0
    var urlSessionQueue = OperationQueue()

    init?(settings: NDT7Settings, url: URL) {
        self.url = url
        self.settings = settings
        var urlRequest = URLRequest(url: self.url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: settings.timeout.ioTimeout)
        for (header, value) in settings.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        if #available(iOS 13.0, *),
            enableiOS13Socket,
            self.url.absoluteString.contains("upload") {
            webSocket = nil
            super.init()
            urlSessionQueue.maxConcurrentOperationCount = 1
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: urlSessionQueue)
            webSocketTask = urlSession.webSocketTask(with: urlRequest)
            if let webSocketTask = webSocketTask as? URLSessionWebSocketTask {
                webSocketTask.resume()
                webSocketMessage()
            }
        } else {
            webSocket = WebSocket(request: urlRequest)
            webSocketTask = nil
            super.init()
            webSocket?.allowSelfSignedSSL = settings.skipTLSCertificateVerification
            webSocket?.delegate = self
        }
    }

    deinit {
        webSocket?.delegate = nil
        webSocket?.close()
    }
}

/// Mark: URLSessionWebSocketDelegate
@available(iOS 13, *)
extension WebSocketWrapper: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol
        protocol: String?) {
        webSocketOpen()
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        webSocketClose(0, reason: "", wasClean: false)
    }

    func webSocketMessage() {
        guard let webSocketTask = webSocketTask as? URLSessionWebSocketTask,
            webSocketTask.state == .running else {
            return
        }
        webSocketTask.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                if error.localizedDescription.contains("Bad address") {
                    // Apple framework is not reliable.
                    // it's getting a lot of bad address errors.
                    self.webSocketError(error as NSError)
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    self.webSocketMessageText(text)
                case .data(let data):
                    self.webSocketMessageData(data)
                @unknown default:
                    fatalError()
                }
                self.webSocketMessage()
            }
        }
    }
}

extension WebSocketWrapper {

    func open(_ interval: TimeInterval = 0.5, _ maxRetries: UInt = 10) {
        logNDT7("WebSocket \(url.absoluteString) opening. Max retries: \(maxRetries)")
        if #available(iOS 13.0, *),
            enableiOS13Socket,
            self.url.absoluteString.contains("upload"),
            let webSocketTask = webSocketTask as? URLSessionWebSocketTask {
            webSocketTask.resume()
        } else {
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
    }

    func close() {
        logNDT7("WebSocket \(url.absoluteString) closing")
        webSocket?.close()
        if #available(iOS 13.0, *),
            enableiOS13Socket,
            self.url.absoluteString.contains("upload"),
            let webSocketTask = webSocketTask as? URLSessionWebSocketTask {
            webSocketTask.cancel()
        }
    }

    func send(_ message: Any, maxBuffer: Int) -> Int? {
        if #available(iOS 13.0, *),
            enableiOS13Socket,
            self.url.absoluteString.contains("upload"),
            let webSocketTask = webSocketTask as? URLSessionWebSocketTask,
            let data = message as? Data {
            let messagedata = URLSessionWebSocketTask.Message.data(Data.randomDataNetworkElement())
            webSocketTask.send(messagedata, completionHandler: { [weak self] (error) in
                guard let self = self else { return }
                if error == nil {
                    self.dataCountSent += data.count
                }
            })
            return 0
        } else {
            guard let buffer = webSocket?.ws.outputBytesLength, buffer < maxBuffer else { return nil }
            if open {
                webSocket?.send(message)
                return buffer
            } else {
                logNDT7("WebSocket \(url.absoluteString) did not send message. WebSocket not connected")
                return nil
            }
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
        dataCountSent = 0
        dataCountReceived = 0
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
        dataCountReceived += data.count
        delegate?.message(webSocket: self, message: data)
    }
}
