/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

@testable import ChatServer
@testable import ChatServerTesting

class DummyUserTests: XCTestCase {
    func testMakeDummyUser() {
        let (user, state) = TestData.makeDummyUser(
            id: 1,
            state: .active,
            name: "Dummy",
            email: "dummy@example.com",
            picture: nil,
            password: "password")

        XCTAssertEqual(state, .active)
        XCTAssertEqual(user.name, "Dummy")
        XCTAssertEqual(user.email, "dummy@example.com")
        XCTAssertEqual(user.picture, nil)
        XCTAssertEqual(user.loginKey, "V0nrrLcHcPcf1nuQoTnBIDKczv+LbXjJeTKyL5LTW+o=")
        XCTAssertEqual(user.passwordVerificationKey, "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=")
        XCTAssertEqual(user.encryptionPubkey, "DHsX+0kl70HiXXWWauoQviqWRY3/jMkGtLxTEsAEBSg=")
    }
}
