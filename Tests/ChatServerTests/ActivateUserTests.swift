/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

@testable import ChatServerTesting
@testable import ChatServer
@testable import FluentServices

class ActivateUserTests: XCTestCase {
    private func addTestData() {
        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.usersWithPendingUser)
        FluentServicesTesting.addConversations(TestData.conversations)
        FluentServicesTesting.addPermissions([
            "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b": [
                ConversationPermission(
                    conversationId: "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b", creatorId: 1, ownerId: 1, validFrom: DateString(Date()),
                    conversationKeyId: "1111", conversationKey: "dummy", signature: "dummy"),
            ],
            "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35": [
                ConversationPermission(
                    conversationId: "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35", creatorId: 1, ownerId: 1, validFrom: DateString(Date()),
                    conversationKeyId: "2222", conversationKey: "dummy", signature: "dummy"),
            ],
        ])
    }

    private var _ctx: RequestContext!

    override func setUp() {
        super.setUp()
        addTestData()
        let servicesFactory = FluentServicesFactory(logger: LogServiceStub(), authTokens: AuthTokenServiceDummy())
        _ctx = servicesFactory.makeRequestContext(workspace: "test", userID: 1)
    }

    func testJustActivate() throws {
        try _ctx.throwingTransaction({ services in
            XCTAssertEqual(services.users.withID(2).successValue??.state, .pending)
        })

        let userUpdate = UserUpdate(state: .active, name: nil, email: nil, picture: nil)
        let result = Operation.updateUser(ctx: _ctx, userID: 2, update: userUpdate, permissions: [])

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .noContent)

        try _ctx.throwingTransaction({ services in
            XCTAssertEqual(services.users.withID(2).successValue??.state, .active)
        })
    }

    func testActivateAndAddPermissions() throws {
        let userUpdate = UserUpdate(state: .active, name: nil, email: nil, picture: nil)
        let newPermissions = [
            ConversationPermission(
                conversationId: "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
                creatorId: 1, ownerId: 2, validFrom: DateString(Date()),
                conversationKeyId: "1111", conversationKey: "dummy", signature: "dummy"),
            ConversationPermission(
                conversationId: "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35",
                creatorId: 1, ownerId: 2, validFrom: DateString(Date()),
                conversationKeyId: "2222", conversationKey: "dummy", signature: "dummy"),
            ]

        try _ctx.throwingTransaction({ services in
            XCTAssertEqual(services.users.withID(2).successValue??.state, .pending)
        })

        let result = Operation.updateUser(ctx: _ctx, userID: 2, update: userUpdate, permissions: newPermissions)

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .noContent)

        try _ctx.throwingTransaction({ services in
            XCTAssertEqual(services.users.withID(2).successValue??.state, .active)

            guard case let .success(permissionsFromService) = services.conversationPermissions.permissions(forOwner: 2) else {
                XCTFail()
                return
            }
            XCTAssertEqual(
                permissionsFromService["6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b"]!,
                [newPermissions[0]])
            XCTAssertEqual(
                permissionsFromService["d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35"]!,
                [newPermissions[1]])
        })
    }
}
