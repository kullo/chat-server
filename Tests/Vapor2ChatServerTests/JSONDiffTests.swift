/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

class JSONDiffTests: XCTestCase {
    func testNull() {
        XCTAssertTrue(JSONDiff.diff(NSNull(), contains: NSNull()))
        XCTAssertTrue(JSONDiff.diff("Hello, world", contains: NSNull()))

        XCTAssertFalse(JSONDiff.diff(NSNull(), contains: "Hello, world"))
    }

    func testNumber() {
        XCTAssertTrue(JSONDiff.diff(42, contains: 42))
        XCTAssertTrue(JSONDiff.diff(0.5, contains: 0.5))
        XCTAssertTrue(JSONDiff.diff(true, contains: true))
        XCTAssertTrue(JSONDiff.diff(false, contains: false))

        XCTAssertFalse(JSONDiff.diff(21, contains: 42))
    }

    func testString() {
        XCTAssertTrue(JSONDiff.diff("Hello, world", contains: "Hello, world"))

        XCTAssertFalse(JSONDiff.diff("Bye, world", contains: "Hello, world"))
    }

    func testArray() {
        XCTAssertTrue(
            JSONDiff.diff([], contains: []))
        XCTAssertTrue(
            JSONDiff.diff(["hello", 123, NSNull()], contains: ["hello", 123, NSNull()]))
        XCTAssertTrue(
            JSONDiff.diff(["hello", 123, NSNull()], contains: ["hello", NSNull(), NSNull()]))
        XCTAssertTrue(
            JSONDiff.diff(["hello", 123, NSNull()], contains: [NSNull(), NSNull(), NSNull()]))

        XCTAssertFalse(
            JSONDiff.diff(["hello", 123, NSNull()], contains: [NSNull(), NSNull()]))
        XCTAssertFalse(
            JSONDiff.diff(["hello", 123, NSNull()], contains: [NSNull(), NSNull(), NSNull(), NSNull()]))
    }

    func testObject() {
        XCTAssertTrue(JSONDiff.diff(
            ["a": 1, "b": "x", "c": NSNull()],
            contains: ["a": 1, "b": "x", "c": NSNull()]))
        XCTAssertTrue(JSONDiff.diff(
            ["a": 1, "b": "x", "c": NSNull()],
            contains: ["a": 1, "b": "x"]))
        XCTAssertTrue(JSONDiff.diff(
            ["a": 1, "b": "x", "c": NSNull()],
            contains: ["b": "x"]))
        XCTAssertTrue(JSONDiff.diff(
            ["a": 1, "b": "x", "c": NSNull()],
            contains: ["a": NSNull(), "b": "x", "c": NSNull()]))
        XCTAssertTrue(JSONDiff.diff([String: Any](), contains: [String: Any]()))
    }
}
