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

class NewConversationPermissionsTests: XCTestCase {
    private func addTestData() {
        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.users)
        FluentServicesTesting.addConversations(TestData.conversations)
        FluentServicesTesting.addPermissions(TestData.permissions)
    }

    private let _existingConvID = TestData.conversations.first!.id
    private var _ctx: RequestContext!

    override func setUp() {
        super.setUp()
        addTestData()
        let servicesFactory = FluentServicesFactory(logger: LogServiceStub(), authTokens: AuthTokenServiceDummy())
        _ctx = servicesFactory.makeRequestContext(workspace: "test", userID: 1)
    }

    func testNewPermissions() throws {
        let validFromDate = DateString(Date())
        let newPermissions = [ConversationPermission(
            conversationId: _existingConvID, creatorId: 1, ownerId: 1, validFrom: validFromDate,
            conversationKeyId: "asdf", conversationKey: "1234", signature: "TODO")]

        var permissionsBefore = [ConversationPermission]()
        try _ctx.throwingTransaction({ services in
            permissionsBefore = services.conversationPermissions
                .permissions(forConversation: _existingConvID)
                .successValue!
                .sorted()
        })

        let result = Operation.addPermissions(ctx: _ctx, convID: _existingConvID, permissions: newPermissions)

        try _ctx.throwingTransaction({ services in
            let permissionsAfter = services.conversationPermissions
                .permissions(forConversation: _existingConvID)
                .successValue!
                .sorted()
            guard case let .success(success) = result else {
                XCTFail("\(result)")
                return
            }
            XCTAssertEqual(success.status, .noContent)
            XCTAssertEqual(permissionsAfter, permissionsBefore + newPermissions)
        })
    }

    func testNewPermissionsForNonexistentConversation() {
        let validFromDate = DateString(Date())
        let newPermissions = [ConversationPermission(
            conversationId: _existingConvID, creatorId: 1, ownerId: 1, validFrom: validFromDate,
            conversationKeyId: "asdf", conversationKey: "1234", signature: "TODO")]

        let result = Operation.addPermissions(ctx: _ctx, convID: "asdf", permissions: newPermissions)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .notFound)
    }

    func testNewPermissionsWithUnauthenticatedCreator() {
        let validFromDate = DateString(Date())
        let newPermissions = [ConversationPermission(
            conversationId: _existingConvID, creatorId: 2, ownerId: 1, validFrom: validFromDate,
            conversationKeyId: "asdf", conversationKey: "1234", signature: "TODO")]

        let result = Operation.addPermissions(ctx: _ctx, convID: _existingConvID, permissions: newPermissions)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .unprocessableEntity)
    }

    func testNewPermissionsWithNonexistentOwner() {
        let validFromDate = DateString(Date())
        let newPermissions = [ConversationPermission(
            conversationId: _existingConvID, creatorId: 1, ownerId: 42, validFrom: validFromDate,
            conversationKeyId: "asdf", conversationKey: "1234", signature: "TODO")]

        let result = Operation.addPermissions(ctx: _ctx, convID: _existingConvID, permissions: newPermissions)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .unprocessableEntity)
    }

    func testNewPermissionsWithConflictingConversationKeyID() {
        let secondConvID = TestData.conversations[1].id
        let validFromDate = DateString(Date())
        let newPermissions = [ConversationPermission(
            conversationId: secondConvID, creatorId: 1, ownerId: 1, validFrom: validFromDate,
            conversationKeyId: "961e57c49ac08a897349d862ccc3f2f2", conversationKey: "1234",
            signature: "TODO")]

        let result = Operation.addPermissions(ctx: _ctx, convID: secondConvID, permissions: newPermissions)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .conflict)
    }
}
