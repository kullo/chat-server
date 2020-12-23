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

class NewDeviceTests: XCTestCase {
    private func addTestData() {
        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(TestData.users)
    }

    private let _newID = "11507a0e2f5e69d5dfa40a62a1bd7b6ee57e6bcd85c67c9b8431b36fff21c437"
    private var _ctx: RequestContext!

    override func setUp() {
        super.setUp()
        addTestData()
        let servicesFactory = FluentServicesFactory(logger: LogServiceStub(), authTokens: AuthTokenServiceDummy())
        _ctx = servicesFactory.makeRequestContext(workspace: "test", userID: 1)
    }

    func testAddFirstDevice() {
        let newDevice = Device(
            id: "asdf", ownerId: 1, idOwnerIdSignature: "asdf", pubkey: "asdf",
            state: .pending, blockTime: nil)
        let expectedDevice = Device(
            id: "asdf", ownerId: 1, idOwnerIdSignature: "asdf", pubkey: "asdf",
            state: .active, blockTime: nil)

        let result = Operation.addDevice(ctx: _ctx, device: newDevice)

        guard case let .success(successResult) = result else {
            XCTFail("\(result)")
            return
        }
        XCTAssertEqual(successResult.status, .ok)
        XCTAssertEqual(successResult.data, expectedDevice)
    }
}
