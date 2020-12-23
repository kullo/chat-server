/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class MessageNewTests: WebSocketTestCase {
    func testUnparsableMessage() throws {
        var closed = false
        connection.fakeClose = { _, _ in
            closed = true
        }

        try connection.onText?(connection, "Hello, world.")
        XCTAssertTrue(closed)
    }

    func testMalformedNewMessageRequest() throws {
        // missing data object
        let request = """
            {
                "type": "message.add",
                "id": 42
            }
            """

        var response = ""
        connection.fakeSend = { text in
            response = text
        }

        try connection.onText?(connection, request)
        AssertJSONError(response: response, requestID: 42)
    }

    func testNewMessageRequest() {
        let request = """
            {
                "type": "message.add",
                "id": 42,
                "data": {
                    "context": {
                        "version": 1,
                        "parentMessageId": 0,
                        "previousMessageId": 0,
                        "conversationKeyId": "ef0a99b55a599f09e4f8663ee15864ac",
                        "deviceKeyId": "123abc"
                    },
                    "encryptedMessage": "(base64-encoded data)"
                }
            }
            """
        let expected = """
            {
                "type": "response",
                "meta": {
                    "requestId": 42,
                    "error": null
                },
                "data": {
                    "id": 1,
                    "revision": 0
                }
            }
            """
        let expectedEvent = """
            {
                "type": "message.added",
                "data": {
                    "id": 1,
                    "revision": 0,
                    "context": {
                        "version": 1,
                        "parentMessageId": 0,
                        "previousMessageId": 0,
                        "conversationKeyId": "ef0a99b55a599f09e4f8663ee15864ac",
                        "deviceKeyId": "123abc"
                    },
                    "encryptedMessage": "(base64-encoded data)"
                }
            }
            """

        assertSendsEvent(containing: expectedEvent) {
            assert(responseFor: request, contains: expected)
        }
    }
}
