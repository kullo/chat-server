/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class UserGetTests: WebSocketTestCase {
    func testGetNonexistentUser() throws {
        let request = """
            {
                "type": "user.get",
                "id": 333,
                "data": {
                    "id": 222
                }
            }
            """

        var response = ""
        connection.fakeSend = { text in
            response = text
        }

        try connection.onText?(connection, request)
        AssertJSONError(response: response, requestID: 333)
    }

    func testGetUser() {
        let request = """
            {
                "type": "user.get",
                "id": 333,
                "data": {
                    "id": 1
                }
            }
            """
        let expected = """
            {
                "type": "response",
                "meta": {
                    "requestId": 333,
                    "error": null
                },
                "data": {
                    "id": 1,
                    "state": "active",
                    "name": "The Answer",
                    "picture": "https://www.example.com/theanswer.jpg",
                    "encryptionPubkey": "DHsX+0kl70HiXXWWauoQviqWRY3/jMkGtLxTEsAEBSg="
                }
            }
            """

        assert(responseFor: request, contains: expected)
    }
}
