/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

@testable import ChatServer
@testable import ChatServerTesting
@testable import FluentServices

class ConversationJoinTests: WebSocketTestCase {
    override func makeConversations() -> [Conversation] {
        var conv = TestData.conversations.first!
        conv.participantIds.removeAll()
        return [conv]
    }

    func testJoinNonexistentConversation() {
        let request = """
            {
                "type": "conversation.join",
                "id": 333,
                "data": {
                    "id": "7945bc2d6e4fd0a0be5216460557bef483a80b6af0acbcdf06866f5c473b9367"
                }
            }
            """

        let response = getSuccessfulResponse(request: request)
        AssertJSONError(response: response, requestID: 333)
    }

    func testJoinConversation() {
        let convID = TestData.conversations.first!.id
        let request = """
            {
                "type": "conversation.join",
                "id": 333,
                "data": {
                    "id": "\(convID)"
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
                    "type": "channel",
                    "id": "\(convID)",
                    "participantIds": [1],
                    "title": "Some Channel"
                }
            }
            """
        let expectedEvent = """
            {
                "type": "conversation.updated",
                "data": {
                    "type": "channel",
                    "id": "\(convID)",
                    "participantIds": [1],
                    "title": "Some Channel"
                }
            }
            """

        assertSendsEvent(containing: expectedEvent) {
            assert(responseFor: request, contains: expected)
        }
    }
}
