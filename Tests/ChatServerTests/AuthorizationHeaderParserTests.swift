/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

@testable import ChatServer
@testable import ChatServerTesting

class AuthorizationHeaderParserTests: XCTestCase {
    private var _parser = AuthorizationHeaderParser(logger: LogServiceStub())

    func testGoodHeader() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V1 loginKey=\"login key\", signature=\"device id,signature\"")

        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.loginKey, "login key")
        XCTAssertEqual(parsed?.deviceID, "device id")
        XCTAssertEqual(parsed?.signature, "signature")
    }

    func testExtraKeyValuePart() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V1 loginKey=\"login key\", signature=\"device id,signature\", foo=\"extra\"")

        XCTAssertNil(parsed)
    }

    func testWrongVersion() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V2 loginKey=\"login key\", signature=\"device id,signature\"")

        XCTAssertNil(parsed)
    }

    func testMissingLoginKey() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V1 signature=\"device id,signature\"")

        XCTAssertNil(parsed)
    }

    func testMissingSignature() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V1 loginKey=\"login key\"")

        XCTAssertNil(parsed)
    }

    func testNoKeyValuePart() {
        let parsed = _parser.parseAuthHeader(
            "KULLO_V1")

        XCTAssertNil(parsed)
    }
}
