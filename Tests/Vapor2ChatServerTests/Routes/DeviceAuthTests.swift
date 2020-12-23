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

class DeviceAuthTests: RouterTestCase {
    override func makeDevices() -> [Device] {
        return [
            Device(
                id: "123abc",
                ownerId: 1,
                idOwnerIdSignature: "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                pubkey: "WTf5bFDh+3shgdJpHkTb4mxLE6IHHB/rj1KbehMaT9Q=",
                state: .active,
                blockTime: nil
            ),
            Device(
                id: "456def",
                ownerId: 1,
                idOwnerIdSignature: "asdf",
                pubkey: "zVclGMiApcoBmoo4guY3a/vb4bpt8JPu7RLGx1oS9Q0=",
                state: .pending,
                blockTime: nil
            ),
        ]
    }

    func testAuthWorksWithActiveDevice() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices")
        req.addAuth(deviceID: "123abc")

        let resp = try router.respond(to: req)
        XCTAssertEqual(resp.status, .ok)
    }

    func testDeviceMustBeActiveForAuth() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices")
        req.addAuth(deviceID: "456def")

        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }
}
