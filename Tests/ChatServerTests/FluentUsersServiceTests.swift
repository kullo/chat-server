/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent
import XCTest

@testable import ChatServer
@testable import ChatServerTesting
@testable import FluentServices

class FluentUsersServiceTests: XCTestCase {
    private let _users = TestData.users
    private var _service: FluentUsersService!

    override func setUp() {
        super.setUp()

        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(_users)

        _service = FluentUsersService(Database.default!)
    }

    func testGetAllUsers() {
        let usersFromService = _service.all()

        XCTAssertEqual(
            usersFromService.successValue,
            [
                User.fromNewUser(_users[0].0, id: 1, state: _users[0].1),
                User.fromNewUser(_users[1].0, id: 2, state: _users[1].1),
            ])
    }

    func testUserWithID() {
        let user = _service.withID(2)

        XCTAssertEqual(
            user.successValue, User.fromNewUser(_users[1].0, id: 2, state: _users[1].1))
    }

    func testUserWithEmail() {
        let user = _service.withEmail("answer@example.com")

        XCTAssertEqual(
            user.successValue, User.fromNewUser(_users[0].0, id: 1, state: _users[0].1))
    }

    func testUpdateConflict() {
        let result = _service.update(
            id: 2,
            with: UserUpdate(state: nil, name: nil, email: "answer@example.com", picture: nil))

        switch result {
        case .success:
            XCTFail()
        case let .error(error):
            XCTAssertEqual(error as? UsersServiceError, .conflictingEmail)
        }
    }
}
