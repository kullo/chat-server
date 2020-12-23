/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Vapor
import WebSockets

@testable import Vapor2ChatServer

final class WebSocketFake: WebSocketProtocol {
    var fakePing: (() throws -> Void)? = nil
    var fakeSend: ((String) throws -> Void)? = nil
    var fakeClose: ((UInt16?, String?) throws -> Void)? = nil

    func ping() throws {
        try fakePing?()
    }

    func send(_ text: String) throws {
        try fakeSend?(text)
    }

    func close(statusCode: UInt16? = nil, reason: String? = nil) throws {
        try fakeClose?(statusCode, reason)
    }

    var onText: ((WebSocketFake, String) throws -> ())? = nil
    var onBinary: ((WebSocketFake, Bytes) throws -> ())? = nil
    var onClose: ((WebSocketFake, UInt16?, String?, Bool) throws -> ())? = nil
}
