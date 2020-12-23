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

class UserAuthTests: RouterTestCase {
    override func makeUsers() -> [(NewUser, User.State)] {
        return TestData.usersWithPendingUser
    }

    func testAuthWorksWithActiveUser() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices")
        req.addAuth(deviceID: "123abc")

        let resp = try router.respond(to: req)
        XCTAssertEqual(resp.status, .ok)
    }

    func testUserMustBeActiveForAuth() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices")
        req.addAuth(deviceID: "456def")

        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }
}
