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
@testable import Vapor2ChatServer

/// sourcery: disableTests
class WebSocketTestCase: XCTestCase {
    private var _controller: WebSocketController<WebSocketFake>!
    private(set) var connection: WebSocketFake!

    override func setUp() {
        super.setUp()
        Testing.onFail = XCTFail

        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.users)
        FluentServicesTesting.addDevices(TestData.devices)
        FluentServicesTesting.addConversations(makeConversations())
        FluentServicesTesting.addPermissions(TestData.permissions)

        let servicesFactory = FluentServicesFactory(
            logger: LogServiceStub(), authTokens: AuthTokenManager())
        _controller = WebSocketController<WebSocketFake>(
            servicesFactory: servicesFactory,
            requestHandlers: App.webSocketRequestHandlers,
            events: App.webSocketEvents(for: servicesFactory))

        connection = WebSocketHelpers.makeWebSocketConnection(wsController: _controller)
    }

    func makeConversations() -> [Conversation] {
        return TestData.conversations
    }

    override func tearDown() {
        try! connection.onClose?(connection, nil, nil, true)
        super.tearDown()
    }

    func getSuccessfulResponse(
        request: String,
        file: StaticString = #file,
        line: UInt = #line) -> String {

        var response = ""
        var responseCount = 0
        connection.fakeSend = { text in
            response = text
            responseCount += 1
        }

        XCTAssertNoThrow(try connection.onText?(connection, request), file: file, line: line)
        XCTAssertEqual(
            responseCount, 1,
            "Received \(responseCount) responses, expected 1",
            file: file, line: line)

        return response
    }

    func assert(
        responseFor request: String,
        contains expected: String,
        file: StaticString = #file,
        line: UInt = #line) {

        let response = getSuccessfulResponse(request: request, file: file, line: line)
        AssertJSON(response: response, contains: expected, file: file, line: line)
    }

    func assertSendsEvent(
        containing expectedEvent: String,
        file: StaticString = #file,
        line: UInt = #line,
        block: () -> Void) {

        assertSendsEvent(
            containing: expectedEvent, controller: _controller,
            file: file, line: line,
            block: block)
    }
}
