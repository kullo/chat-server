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

class NewMessageTests: XCTestCase {
    private func addTestData() {
        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.users)
        FluentServicesTesting.addDevices(TestData.devices)
        FluentServicesTesting.addConversations(TestData.conversations)
        FluentServicesTesting.addPermissions(TestData.permissions)
        FluentServicesTesting.addMessages(TestData.messages)
    }

    private var _ctx: RequestContext!

    override func setUp() {
        super.setUp()
        addTestData()
        let servicesFactory = FluentServicesFactory(logger: LogServiceStub(), authTokens: AuthTokenServiceDummy())
        _ctx = servicesFactory.makeRequestContext(workspace: "test", userID: 1)
    }

    func testNewMessageWithBadPreviousMessage() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 0, previousMessageId: 2,
                conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .unprocessableEntity)
    }

    func testNewMessageWithNonexistentConversationKey() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 0, previousMessageId: 1,
                conversationKeyId: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .notFound)
    }

    func testNewMessageWithObsoleteConversationKey() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 0, previousMessageId: 1,
                conversationKeyId: "961e57c49ac08a897349d862ccc3f2f2", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .conflict)
    }

    func testNewMessageWithUnownedDevice() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 0, previousMessageId: 1,
                conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "456def"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .notFound)
    }

    func testNewMessage() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 0, previousMessageId: 1,
                conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .ok)
        XCTAssertGreaterThan(successResult.data.id, 0)
        XCTAssertEqual(
            successResult.data.timeSent.timeIntervalSinceReferenceDate,
            Date().timeIntervalSinceReferenceDate,
            accuracy: 1)
        XCTAssertEqual(successResult.data.revision, 0)
        XCTAssertEqual(successResult.data.context, newMessage.context)
        XCTAssertEqual(successResult.data.encryptedMessage, newMessage.encryptedMessage)
    }

    func testNewMessageWithBadParentMessage() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 2, previousMessageId: 1,
                conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .error(error) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(error.status, .unprocessableEntity)
    }

    func testNewMessageWithParent() {
        let newMessage = NewMessage(
            context: MessageContext(
                version: 1, parentMessageId: 1, previousMessageId: 0,
                conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "123abc"),
            encryptedMessage: "(base64-encoded data)")

        let result = Operation.addMessage(ctx: _ctx, newMessage: newMessage)

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .ok)
        XCTAssertGreaterThan(successResult.data.id, 0)
        XCTAssertEqual(
            successResult.data.timeSent.timeIntervalSinceReferenceDate,
            Date().timeIntervalSinceReferenceDate,
            accuracy: 1)
        XCTAssertEqual(successResult.data.revision, 0)
        XCTAssertEqual(successResult.data.context, newMessage.context)
        XCTAssertEqual(successResult.data.encryptedMessage, newMessage.encryptedMessage)
    }
}
