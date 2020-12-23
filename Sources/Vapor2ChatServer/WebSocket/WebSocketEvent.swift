/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation

struct WebSocketEvent {
    let recipientUserIDs: Set<Int>? // nil == all
    let type: String
    let body: AnyEncodable
    let origin: ObjectIdentifier?

    func shouldBeSentTo(userID: Int) -> Bool {
        guard let recipientUserIDs = recipientUserIDs else { return true }
        return recipientUserIDs.contains(userID)
    }
}
