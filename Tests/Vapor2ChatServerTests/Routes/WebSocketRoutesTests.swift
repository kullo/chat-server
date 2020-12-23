/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

@testable import Vapor2ChatServer

class WebSocketRoutesTests: RouterTestCase {
    override func setUp() {
        super.setUp()

        let controller = WebSocketController<WebSocket>(
            servicesFactory: servicesFactory,
            requestHandlers: App.webSocketRequestHandlers,
            events: App.webSocketEvents(for: servicesFactory))
        let auth = HeaderAuthMiddleware(
            users: servicesFactory.makeReadingUsers(),
            devices: servicesFactory.makeReadingDevices(),
            logger: logger)

        try! router.collection(
            WebSocketRoutes(
                headerAuth: auth,
                queryAuth: QueryTokenAuthMiddleware(authTokens: servicesFactory.authTokens),
                servicesFactory: servicesFactory,
                controller: controller))
    }

    func testMakeURLRequiresAuth() throws {
        AssertRequiresAuth(
            try Request.make(method: .post, path: "/v1/test/ws_urls"),
            router: router)
    }

    func testMakeURL() throws {
        let req = try Request.make(method: .post, path: "/v1/test/ws_urls")
        req.addAuth()

        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .ok)
        AssertIsJSON(res)
        try res.assertJSON("socketUrl", passes: { value in
            let url = URL(string: value.string ?? "")
            return (url?.scheme?.starts(with: "ws") ?? false)
                && (url?.query?.starts(with: "token=") ?? false)
        })
    }

    func testConnectToURLWithoutToken() throws {
        let req = try Request.make(method: .get, path: "/ws")
        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    func testConnectToURLWithBadToken() throws {
        let req = try Request.make(method: .get, path: "/ws?token=asdf")
        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    private func getAuthToken() throws -> String? {
        let req = try Request.make(method: .post, path: "/v1/test/ws_urls")
        req.addAuth()
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .ok)

        guard
            let socketURLString = res.json?["socketUrl"]?.string,
            let socketURL = URLComponents(string: socketURLString)
            else { return nil }
        return socketURL.queryItems?.first(where: { $0.name == "token"})?.value
    }

    func testConnectToURL() throws {
        guard let token = try getAuthToken() else {
            XCTFail()
            return
        }

        let req = try Request.make(method: .get, path: "/ws?token=" + token)
        XCTAssertThrowsError(
            try router.respond(to: req),
            "should throw WS format erorr",
            { error in
                XCTAssertNotNil(error as? WebSocket.FormatError)
            }
        )
    }
}
