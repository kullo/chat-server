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

class NewConversationTests: XCTestCase {
    private func addTestData() {
        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.users)
        FluentServicesTesting.addConversations(TestData.conversations)
    }

    private let _newID = "11507a0e2f5e69d5dfa40a62a1bd7b6ee57e6bcd85c67c9b8431b36fff21c437"
    private var _ctx: RequestContext!

    override func setUp() {
        super.setUp()
        addTestData()
        let servicesFactory = FluentServicesFactory(logger: LogServiceStub(), authTokens: AuthTokenServiceDummy())
        _ctx = servicesFactory.makeRequestContext(workspace: "test", userID: 1)
    }

    func testNewGroup() throws {
        let newConv = Conversation(id: _newID, type: .group, title: "Another Group", participantIds: [1])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .noContent)

        try _ctx.throwingTransaction({ services in
            guard case let .success(convFromService) = services.conversations.conversation(id: _newID) else {
                XCTFail()
                return
            }
            XCTAssertEqual(convFromService, newConv)
        })
    }

    func testNewGroupWithConflictingID() {
        let newConv = Conversation(id: TestData.conversations.first!.id, type: .group, title: "Another Group", participantIds: [1])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .conflict)
    }

    func testNewGroupWithConflictingParticipants() {
        let newConv = Conversation(id: _newID, type: .group, title: "Another Group", participantIds: [2, 1])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .conflict)
    }

    func testNewChannel() throws {
        let newConv = Conversation(id: _newID, type: .channel, title: "Another Channel", participantIds: [1])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .noContent)

        try _ctx.throwingTransaction({ services in
            guard case let .success(convFromService) = services.conversations.conversation(id: _newID) else {
                XCTFail()
                return
            }
            XCTAssertEqual(convFromService, newConv)
        })
    }

    func testNewChannelWithConflictingName() {
        let newConv = Conversation(id: _newID, type: .channel, title: "Some Channel", participantIds: [1])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .conflict)
    }

    func testNewChannelWithNonexistentParticipant() {
        let newConv = Conversation(id: _newID, type: .channel, title: "Another Channel", participantIds: [3])

        let result = Operation.addConversation(ctx: _ctx, conversation: newConv, permissions: [])

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .unprocessableEntity)
    }
}
