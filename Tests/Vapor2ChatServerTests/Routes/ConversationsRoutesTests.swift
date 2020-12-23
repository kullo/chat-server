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

class ConversationsRoutesTests: RouterTestCase {
    private let _existingConvID = TestData.conversations.first!.id

    func testCreateRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .post, path: "/v1/test/conversations"),
            router: router)
    }

    func testCreate() throws {
        let convID = "44cb730c420480a0477b505ae68af508fb90f96cf0ec54c6ad16949dd427f13a"
        let req = try Request.makeJSON(method: .post, path: "/v1/test/conversations", body: """
        {
            "conversation": {
                "id": "\(convID)",
                "type": "channel",
                "title": "New channel",
                "participantIds": [1, 2]
            },
            "permissions": [
                {
                    "conversationId": "\(convID)",
                    "conversationKeyId": "asdf",
                    "conversationKey": "(encrypted for user 1, base64 encoded)",
                    "ownerId": 1,
                    "creatorId": 1,
                    "validFrom": "2018-03-01T11:11:11Z",
                    "signature": "(TODO)"
                },
                {
                    "conversationId": "\(convID)",
                    "conversationKeyId": "asdf",
                    "conversationKey": "(encrypted for user 2, base64 encoded)",
                    "ownerId": 2,
                    "creatorId": 1,
                    "validFrom": "2018-03-01T11:11:11Z",
                    "signature": "(TODO)"
                }
            ]
        }
        """)
        req.addAuth()
        XCTAssertEqual(
            services.conversationPermissions.permissions(forConversation: convID).successValue?.count,
            0)

        let expectedEvents = [
            """
            {
                "type": "conversation.added",
                "data": {
                    "id": "\(convID)",
                    "type": "channel",
                    "title": "New channel",
                    "participantIds": [1, 2]
                }
            }
            """,
            """
            {
                "type": "conversation_permission.added",
                "data": {
                    "conversationId": "\(convID)",
                    "conversationKeyId": "asdf",
                    "conversationKey": "(encrypted for user 1, base64 encoded)",
                    "ownerId": 1,
                    "creatorId": 1,
                    "validFrom": "2018-03-01T11:11:11Z",
                    "signature": "(TODO)"
                }
            }
            """,
        ]

        assertSendsEvents(containing: expectedEvents, controller: makeWebSocketController()) {
            let res = try! router.respond(to: req)
            XCTAssertEqual(res.status, .noContent)
        }

        XCTAssertEqual(
            services.conversationPermissions.permissions(forConversation: convID).successValue?.count,
            2)
    }

    func testNewPermissionsRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .post, path: "/v1/test/conversations/\(_existingConvID)/permissions"),
            router: router)
    }

    func testNewPermissions() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/conversations/\(_existingConvID)/permissions", body: """
        [
            {
                "conversationId": "\(_existingConvID)",
                "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                "conversationKey": "(encrypted for user 1, base64 encoded)",
                "ownerId": 1,
                "creatorId": 1,
                "validFrom": "2018-03-01T11:11:11Z",
                "signature": "(TODO)"
            },
            {
                "conversationId": "\(_existingConvID)",
                "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                "conversationKey": "(encrypted for user 2, base64 encoded)",
                "ownerId": 2,
                "creatorId": 1,
                "validFrom": "2018-03-01T11:11:11Z",
                "signature": "(TODO)"
            }
        ]
        """)
        req.addAuth()
        let permissionsPre = services.conversationPermissions
            .permissions(forConversation: _existingConvID).successValue!

        let expectedEvent = """
            {
                "type": "conversation_permission.added",
                "data": {
                    "conversationId": "\(_existingConvID)",
                    "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                    "conversationKey": "(encrypted for user 1, base64 encoded)",
                    "ownerId": 1,
                    "creatorId": 1,
                    "validFrom": "2018-03-01T11:11:11Z",
                    "signature": "(TODO)"
                }
            }
            """

        assertSendsEvent(containing: expectedEvent, controller: makeWebSocketController()) {
            let res = try! router.respond(to: req)
            XCTAssertEqual(res.status, .noContent)
        }

        let permissionsPost = services.conversationPermissions
            .permissions(forConversation: _existingConvID).successValue!
        XCTAssertEqual(permissionsPost.count, permissionsPre.count + 2)
    }

    func testListRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .get, path: "/v1/test/conversations"),
            router: router)
    }

    func testList() throws {
        let req = try Request.make(method: .get, path: "/v1/test/conversations")
        req.addAuth()
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .ok)
        AssertJSON(response: res, contains: """
            {
                "objects": [
                    {
                        "type": "channel",
                        "id": "\(_existingConvID)",
                        "participantIds": [1],
                        "title": "Some Channel"
                    },
                    {
                        "type": "group",
                        "id": "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35",
                        "participantIds": [1, 2],
                        "title": "Some Group"
                    }
                ],
                "related": {
                    "permissions": [
                        {
                            "conversationId": "\(_existingConvID)",
                            "conversationKeyId": "961e57c49ac08a897349d862ccc3f2f2",
                            "conversationKey": "99a47eCaRcfC0/0WiiiexgP0C8QwgGDSYWSA2vO380g=",
                            "ownerId": 1,
                            "creatorId": 1,
                            "validFrom": "2018-01-01T00:00:00Z"
                        },
                        {
                            "conversationId": "\(_existingConvID)",
                            "conversationKeyId": "ef0a99b55a599f09e4f8663ee15864ac",
                            "conversationKey": "J2bmzezHTW7U5CeyqPWxMfkM/ZsKeLUC4bP14310TSc=",
                            "ownerId": 1,
                            "creatorId": 1,
                            "validFrom": "2018-01-02T00:00:00Z"
                        }
                    ]
                },
                "meta": {}
            }
            """)
    }

    func testMessagesRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .get, path: "/v1/test/conversations/\(_existingConvID)/messages"),
            router: router)
    }

    func testMessagesInvalidConversation() throws {
        let req = try Request.make(method: .get, path: "/v1/test/conversations/1334/messages")
        req.addAuth()
        AssertThrowsAbortError(try router.respond(to: req), .notFound)
    }

    func testEmptyMessagesList() throws {
        let req = try Request.make(method: .get, path: "/v1/test/conversations/\(_existingConvID)/messages")
        req.addAuth()
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .ok)
        AssertJSON(response: res, contains: """
            {
                "meta": {},
                "objects": []
            }
            """)
    }
}

class ConversationsRoutesTestsWithMessages: RouterTestCase {
    private let _existingConvID = TestData.conversations.first!.id

    override func makeMessages() -> [Conversation.IDType : [NewMessage]] {
        return TestData.messages
    }

    func testMessagesList() throws {
        let req = try Request.make(method: .get, path: "/v1/test/conversations/\(_existingConvID)/messages")
        req.addAuth()
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .ok)
        AssertJSON(response: res, contains: """
            {
                "meta": {},
                "objects": [
                    {
                        "id": 1,
                        "revision": 0,
                        "context": {
                            "version": 1,
                            "parentMessageId": 0,
                            "previousMessageId": 0,
                            "conversationKeyId": "ef0a99b55a599f09e4f8663ee15864ac",
                            "deviceKeyId": "123abc"
                        },
                        "encryptedMessage": "dummy"
                    }
                ]
            }
            """)
    }
}
