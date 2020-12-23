/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

struct WebSocketConnectionMeta {
    let id: ObjectIdentifier
    let baseURL: URLComponents
    let workspace: String
    let userID: Int
}

struct WebSocketConnection<WebSocketType: WebSocketProtocol> {
    let socket: WebSocketType
    let meta: WebSocketConnectionMeta

    var id: ObjectIdentifier { return meta.id }

    init(socket: WebSocketType, baseURL: URLComponents, workspace: String, userID: Int) {
        self.socket = socket
        self.meta = WebSocketConnectionMeta(
            id: ObjectIdentifier(socket), baseURL: baseURL, workspace: workspace, userID: userID)
    }
}
