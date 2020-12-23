/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import HTTP
import Vapor

extension Request {
    static func make(method: HTTP.Method, path: String) throws -> Request {
        let req = Request.makeTest(method: method)
        req.uri = try URI("http://foo.example" + path)
        return req
    }

    static func makeJSON(method: HTTP.Method, path: String, body: String) throws -> Request {
        let req = try make(method: method, path: path)
        req.headers[.contentType] = "application/json"
        req.body = .data(body.makeBytes())
        return req
    }
}
