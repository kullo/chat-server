/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Vapor

protocol WebSocketProtocol: class {
    func ping() throws
    func send(_ text: String) throws
    func close() throws
    func close(statusCode: UInt16?, reason: String?) throws

    var onText: ((Self, String) throws -> ())?  { get set }
    var onBinary: ((Self, Bytes) throws -> ())?  { get set }
    var onClose: ((Self, UInt16?, String?, Bool) throws -> ())? { get set }
}

extension WebSocketProtocol {
    func close() throws {
        try close(statusCode: nil, reason: nil)
    }
}

extension WebSocket: WebSocketProtocol {
    func ping() throws {
        try ping([])
    }
}
