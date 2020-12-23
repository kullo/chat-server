/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class AttachmentsNewTests: WebSocketTestCase {
    private struct AttachmentsNewResponse: Codable {
        let type: String
        let meta: Meta
        let data: [Attachment]

        struct Meta: Codable {
            let requestId: Int
            let error: String?
        }

        struct Attachment: Codable {
            let id: String
            let uploadUrl: URL
        }
    }

    func testCreateAttachments() throws {
        let request = """
            {
                "type": "attachments.add",
                "id": 333,
                "data": {
                    "count": 1
                }
            }
            """

        let response = getSuccessfulResponse(request: request)

        let decoded = try JSONDecoder().decode(AttachmentsNewResponse.self, from: Data(response.utf8))
        XCTAssertEqual(decoded.type, "response")
        XCTAssertEqual(decoded.meta.requestId, 333)
        XCTAssertEqual(decoded.meta.error, nil)
        let attachments = decoded.data
        XCTAssertEqual(attachments.count, 1)
    }

    func testTooManyAttachments() throws {
        let request = """
            {
                "type": "attachments.add",
                "id": 333,
                "data": {
                    "count": 100
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
}
