/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

@testable import ChatServerTesting

class ConversationPermissionGetTests: WebSocketTestCase {
    func testGetPermissionWithBadConversationKeyID() throws {
        let request = """
            {
                "type": "conversation_permission.get",
                "id": 333,
                "data": {
                    "conversationKeyId": "asdf",
                }
            }
            """

        var response = ""
        connection.fakeSend = { text in
            response = text
        }

        try connection.onText?(connection, request)
        AssertJSONError(response: response, requestID: 333)
    }

    func testGetPermission() {
        let request = """
            {
                "type": "conversation_permission.get",
                "id": 333,
                "data": {
                    "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                }
            }
            """
        let expected = """
            {
                "type": "response",
                "meta": {
                    "requestId": 333,
                    "error": null
                },
                "data": {
                    "conversationId": "\(TestData.conversations.first!.id)",
                    "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                    "conversationKey": "99a47eCaRcfC0/0WiiiexgP0C8QwgGDSYWSA2vO380g=",
                    "ownerId": 1,
                    "creatorId": 1,
                    "validFrom": "2018-01-01T00:00:00Z"
                }
            }
            """

        assert(responseFor: request, contains: expected)
    }
}
