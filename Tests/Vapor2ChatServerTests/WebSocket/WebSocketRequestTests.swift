/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class WebSocketRequestTests: WebSocketTestCase {
    func testInvalidType() {
        let request = """
            {
                "type": "invalid",
                "id": 333,
                "data": {
                }
            }
            """

        let response = getSuccessfulResponse(request: request)
        AssertJSONError(response: response, requestID: 333)
    }

}
