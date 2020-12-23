/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Vapor
import XCTest

@testable import Vapor2ChatServer

enum WebSocketHelpers {
    static func makeWebSocketConnection(wsController: WebSocketController<WebSocketFake>) -> WebSocketFake {
        let connection = WebSocketFake()
        let req = try! Request.make(method: .get, path: "dummy")
        req.workspace = "test"
        req.userID = 1
        try! wsController.handleConnection(request: req, connection: connection)
        return connection
    }
}

extension XCTestCase {
    func assertSendsEvent(
        containing expectedEvent: String, controller: WebSocketController<WebSocketFake>,
        file: StaticString = #file, line: UInt = #line,
        block: () -> Void) {

        assertSendsEvents(
            containing: [expectedEvent], controller: controller,
            file: file, line: line, block: block)
    }

    func assertSendsEvents(
        containing expectedEvents: [String], controller: WebSocketController<WebSocketFake>,
        file: StaticString = #file, line: UInt = #line,
        block: () -> Void) {

        let eventsConnection = WebSocketHelpers.makeWebSocketConnection(wsController: controller)
        defer { try! eventsConnection.onClose?(eventsConnection, nil, nil, true) }

        let eventReceivedExpectation = expectation(description: "Event received")
        var receivedEvents = [String]()

        eventsConnection.fakeSend = { text in
            receivedEvents.append(text)
            guard receivedEvents.count <= expectedEvents.count else {
                XCTFail("Received too many events", file: file, line: line)
                return
            }
            if receivedEvents.count == expectedEvents.count {
                eventReceivedExpectation.fulfill()
            }
        }

        block()

        waitForExpectations(timeout: 1) { error in
            if error == nil {
                XCTAssertEqual(receivedEvents.count, expectedEvents.count, file: file, line: line)
                for (received, expected) in zip(receivedEvents, expectedEvents) {
                    AssertJSON(response: received, contains: expected, file: file, line: line)
                }
            }
        }
    }
}
