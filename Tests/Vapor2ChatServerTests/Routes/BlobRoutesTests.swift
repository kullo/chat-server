/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

class BlobRoutesTests: RouterTestCase {
    func testGetNonexistentBlob() throws {
        let req = try Request.make(method: .get, path: "/blob/nonexistent")
        AssertThrowsAbortError(try router.respond(to: req), .notFound)
    }

    func testAddAndGetBlob() throws {
        let testBody = "Hello blob storage".makeBytes()

        // add blob
        let req = try Request.make(method: .put, path: "/blob/someblob")
        req.headers[.contentType] = "x-custom/testing"
        req.body = .data(testBody)
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .noContent)

        // retrieve blob
        let req2 = try Request.make(method: .get, path: "/blob/someblob")
        let res2 = try router.respond(to: req2)

        XCTAssertEqual(res2.status, .ok)
        XCTAssertEqual(res2.headers[.contentType], "x-custom/testing")
        XCTAssertNotNil(res2.body.bytes)
        XCTAssertEqual(res2.body.bytes!, testBody)
    }

    func testDuplicateKey() throws {
        let testBody = "Hello blob storage".makeBytes()

        // add blob
        let req = try Request.make(method: .put, path: "/blob/someblob")
        req.body = .data(testBody)
        let res = try router.respond(to: req)
        XCTAssertEqual(res.status, .noContent)

        // add conflicting blob
        let req2 = try Request.make(method: .put, path: "/blob/someblob")
        req.body = .data(testBody)
        AssertThrowsAbortError(try router.respond(to: req2), .conflict)
    }
}
