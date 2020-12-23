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

class UsersRoutesTestsWithoutUsers: RouterTestCase {
    override func makeUsers() -> [(NewUser, User.State)] {
        return []
    }

    // necessary because devices depend on users via foreign keys
    override func makeDevices() -> [Device] {
        return []
    }

    // necessary because devices depend on users via foreign keys
    override func makeConversations() -> [Conversation] {
        return []
    }

    // necessary because devices depend on users via foreign keys
    override func makePermissions() -> [Conversation.IDType : [ConversationPermission]] {
        return [:]
    }

    func testFirstUserIsInitiallyActive() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users", body: """
            {
                "name": "John Doe",
                "email": "john.doe@example.com",
                "loginKey": "(base64-encoded data)",
                "passwordVerificationKey": "(base64-encoded data)",
                "encryptionPubkey": "(base64-encoded data)",
                "encryptionPrivkey": "(encrypted, base64-encoded data)"
            }
            """)

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .ok)
        AssertJSON(response: response, contains: """
            {
                "user": {
                    "state": "active"
                }
            }
            """)
    }
}

class UsersRoutesTestsWithPendingUser: RouterTestCase {
    override func makeUsers() -> [(NewUser, User.State)] {
        return TestData.usersWithPendingUser
    }

    func testGetPending() throws {
        let request = try Request.make(method: .get, path: "/v1/test/users?state=pending")
        request.addAuth()

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .ok)
        AssertJSON(response: response, contains: """
            {
                "objects": [
                    {
                        "id": 2,
                        "state": "pending",
                        "name": "Another User",
                        "picture": null,
                        "encryptionPubkey": "6DZ23+EtT8CrSLlmJtau9/ZFi4UmrJZ6Zd7RF6M1em8="
                    }
                ],
                "meta": {}
            }
            """)
    }

    func testUpdateRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .patch, path: "/v1/test/users/2"),
            router: router)
    }

    func testUpdateState() throws {
        let existingConvID = TestData.conversations.first!.id
        let request = try Request.makeJSON(method: .patch, path: "/v1/test/users/2", body: """
            {
                "user": {
                    "state": "active",
                },
                "permissions": [
                    {
                        "conversationId": "\(existingConvID)",
                        "conversationKeyId": "0123456789abcdef0123456789abcdef",
                        "conversationKey": "(encrypted for user 2, base64 encoded)",
                        "ownerId": 2,
                        "creatorId": 1,
                        "validFrom": "2018-01-01T11:11:11Z",
                        "signature": "(TODO)"
                    }
                ]
            }
            """)
        request.addAuth()
        XCTAssertEqual(services.users.withID(2).successValue??.state, .pending)
        guard case let .success(permissionBefore) =
            services.conversationPermissions.permission(
                forKey: "0123456789abcdef0123456789abcdef", userID: 2) else {
                    XCTFail()
                    return
        }
        XCTAssertNil(permissionBefore)

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .noContent)
        XCTAssertEqual(services.users.withID(2).successValue??.state, .active)
        guard case let .success(permissionAfter) =
            services.conversationPermissions.permission(
                forKey: "0123456789abcdef0123456789abcdef", userID: 2) else {
                    XCTFail()
                    return
        }
        XCTAssertNotNil(permissionAfter)
    }

    func testUpdateProfile() throws {
        let request = try Request.makeJSON(method: .patch, path: "/v1/test/users/1", body: """
            {
                "user": {
                    "email": "new.email@example.com",
                    "name": "New Name",
                    "picture": "https://example.com/some/picture.jpg"
                }
            }
            """)
        request.addAuth()
        let userBeforeUpdate = services.users.withID(1).successValue!!
        XCTAssertNotEqual(userBeforeUpdate.email, "new.email@example.com")
        XCTAssertNotEqual(userBeforeUpdate.name, "New Name")
        XCTAssertNotEqual(userBeforeUpdate.picture, URL(string: "https://example.com/some/picture.jpg")!)

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .noContent)
        let userAfterUpdate = services.users.withID(1).successValue!!
        XCTAssertEqual(userAfterUpdate.email, "new.email@example.com")
        XCTAssertEqual(userAfterUpdate.name, "New Name")
        XCTAssertEqual(userAfterUpdate.picture, URL(string: "https://example.com/some/picture.jpg")!)
    }
}

class UsersRoutesTests: RouterTestCase {
    func testRegisterWithDuplicateEmailAddress() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users", body: """
            {
                "name": "John Doe",
                "email": "answer@example.com",
                "loginKey": "(base64-encoded data)",
                "passwordVerificationKey": "(base64-encoded data)",
                "encryptionPubkey": "(base64-encoded data)",
                "encryptionPrivkey": "(encrypted, base64-encoded data)"
            }
            """)

        AssertThrowsAbortError(try router.respond(to: request), .conflict)
    }

    func testRegister() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users", body: """
            {
                "name": "John Doe",
                "email": "john.doe@example.com",
                "loginKey": "(base64-encoded data)",
                "passwordVerificationKey": "(base64-encoded data)",
                "encryptionPubkey": "(base64-encoded data)",
                "encryptionPrivkey": "(encrypted, base64-encoded data)"
            }
            """)

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .ok)
        AssertJSON(response: response, contains: """
            {
                "verificationCode": "music pear battery t-shirt",
                "user": {
                    "id": 3,
                    "state": "pending",
                    "name": "John Doe",
                    "picture": null,
                    "encryptionPubkey": "(base64-encoded data)"
                }
            }
            """)
        try response.assertJSON("user", passes: { userJSON in
            guard let userObj = userJSON.object else {
                return false
            }
            return
                userObj["email"] == nil &&
                userObj["loginKey"] == nil &&
                userObj["passwordVerificationKey"] == nil &&
                userObj["encryptionPrivkey"] == nil
        })
    }

    func testGetAllRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .get, path: "/v1/test/users"),
            router: router)
    }

    func testGetAll() throws {
        let request = try Request.make(method: .get, path: "/v1/test/users")
        request.addAuth()

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .ok)
        AssertJSON(response: response, contains: """
            {
                "objects": [
                    {
                        "id": 1,
                        "state": "active",
                        "name": "The Answer",
                        "picture": "https://www.example.com/theanswer.jpg",
                        "encryptionPubkey": "DHsX+0kl70HiXXWWauoQviqWRY3/jMkGtLxTEsAEBSg="
                    },
                    {
                        "id": 2,
                        "state": "active",
                        "name": "Another User",
                        "picture": null,
                        "encryptionPubkey": "6DZ23+EtT8CrSLlmJtau9/ZFi4UmrJZ6Zd7RF6M1em8="
                    }
                ],
                "meta": {}
            }
            """)
    }

    func testGetMeWithBadEmail() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users/get_me", body: """
            {
                "email": "does.not.exist@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM="
            }
            """)

        AssertThrowsAbortError(try router.respond(to: request), .unauthorized)
    }

    func testGetMeWithWrongPVK() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users/get_me", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "1337"
            }
            """)

        AssertThrowsAbortError(try router.respond(to: request), .unauthorized)
    }

    func testGetMe() throws {
        let request = try Request.makeJSON(method: .post, path: "/v1/test/users/get_me", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM="
            }
            """)

        let response = try router.respond(to: request)

        XCTAssertEqual(response.status, .ok)
        AssertJSON(response: response, contains: """
            {
                "user": {
                    "id": 1,
                    "state": "active",
                    "name": "The Answer",
                    "picture": "https://www.example.com/theanswer.jpg",
                    "encryptionPubkey": "DHsX+0kl70HiXXWWauoQviqWRY3/jMkGtLxTEsAEBSg="
                }
            }
            """)
    }
}
