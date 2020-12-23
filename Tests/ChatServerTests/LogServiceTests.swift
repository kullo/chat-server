/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

@testable import ChatServer

private class LogServiceFake: LogService {
    var lastLevel: LogLevel?

    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        lastLevel = level
    }
}

class LogServiceTests: XCTestCase {
    private var _uut: LogServiceFake!

    override func setUp() {
        super.setUp()
        _uut = LogServiceFake()
    }

    func testInfo() {
        _uut.info("test 123 test")
        XCTAssertEqual(_uut.lastLevel, .info)
    }

    func testWarning() {
        _uut.warning("test 123 test")
        XCTAssertEqual(_uut.lastLevel, .warning)
    }

    func testError() {
        _uut.error("test 123 test")
        XCTAssertEqual(_uut.lastLevel, .error)
    }

    func testFatal() {
        _uut.fatal("test 123 test")
        XCTAssertEqual(_uut.lastLevel, .fatal)
    }
}
