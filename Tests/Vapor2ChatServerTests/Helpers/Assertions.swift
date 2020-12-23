/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import HTTP
import Vapor
import XCTest

func AssertIsJSON(_ res: Response, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(res.headers[.contentType], "application/json", file: file, line: line)
}

func AssertJSON(
    response: Response,
    contains partialContent: String,
    file: StaticString = #file,
    line: UInt = #line) {

    AssertIsJSON(response, file: file, line: line)

    do {
        let bodyJSON = try response.getJSONBody()
        try AssertJSON(responseJSON: bodyJSON, contains: partialContent, file: file, line: line)
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

func AssertJSON(
    response: String,
    contains partialContent: String,
    file: StaticString = #file,
    line: UInt = #line) {

    do {
        let responseJSON = try JSONSerialization.jsonObject(
            with: Data(response.utf8), options: [])
        try AssertJSON(responseJSON: responseJSON, contains: partialContent, file: file, line: line)
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

private func AssertJSON(
    responseJSON: Any,
    contains partialContent: String,
    file: StaticString = #file,
    line: UInt = #line) throws {

    let expectedPartialJSON = try JSONSerialization.jsonObject(
        with: Data(partialContent.utf8), options: [])

    XCTAssert(
        JSONDiff.diff(responseJSON, contains: expectedPartialJSON),
        """
        Expected content isn't contained in received content:
        Received: \(formatJSON(responseJSON))
        Expected (partial): \(formatJSON(expectedPartialJSON))
        """,
        file: file,
        line: line)
}

private struct ErrorResponse: Codable {
    let type: String
    let meta: Meta

    struct Meta: Codable {
        let requestId: Int
        let error: String
    }
}

func AssertJSONError(response: String, requestID: Int, file: StaticString = #file, line: UInt = #line) {
    do {
        let decoded = try JSONDecoder().decode(ErrorResponse.self, from: Data(response.utf8))
        XCTAssertEqual(decoded.type, "response", file: file, line: line)
        XCTAssertEqual(decoded.meta.requestId, requestID, file: file, line: line)
    } catch {
        XCTFail("While decoding error response: \(response)", file: file, line: line)
    }
}

private func formatJSON(_ content: Any) -> String {
    let options: JSONSerialization.WritingOptions

    #if os(Linux)
        options = [.prettyPrinted, .sortedKeys]
    #else
        if #available(OSX 10.13, *) {
            options = [.prettyPrinted, .sortedKeys]
        } else {
            options = [.prettyPrinted]
        }
    #endif

    let data = try! JSONSerialization.data(withJSONObject: content, options: options)
    return String(data: data, encoding: .utf8)!
}

func AssertThrowsAbortError<T>(
    _ expression: @autoclosure () throws -> T,
    _ status: Status,
    file: StaticString = #file,
    line: UInt = #line) {

    XCTAssertThrowsError(expression, file: file, line: line) { error in
        if let abortError = error as? AbortError {
            XCTAssertEqual(abortError.status, status, file: file, line: line)
        } else {
            XCTFail("\(error)", file: file, line: line)
        }
    }
}
