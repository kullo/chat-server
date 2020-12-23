/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class DeviceGetTests: WebSocketTestCase {
    func testGetNonexistentDevice() throws {
        let request = """
            {
                "type": "device.get",
                "id": 333,
                "data": {
                    "id": "(device ID as requested)"
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

    func testGetDevice() {
        let request = """
            {
                "type": "device.get",
                "id": 333,
                "data": {
                    "id": "123abc"
                }
            }
            """
        let expected = """
            {
                "type": "response",
                "meta": {
                    "requestId": 333,
                },
                "data": {
                    "id": "123abc",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "WTf5bFDh+3shgdJpHkTb4mxLE6IHHB/rj1KbehMaT9Q=",
                    "state": "active"
                }
            }
            """

        assert(responseFor: request, contains: expected)
    }
}
