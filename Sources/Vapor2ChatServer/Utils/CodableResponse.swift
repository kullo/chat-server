/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import HTTP
import Vapor

class CodableResponse<T: Encodable> {
    private let _encoder = CodecFactory.makeJSONEncoder()
    private let _contentType = "application/json"

    private let _status: Status
    private let _body: T

    init(status: Status = .ok, body: T) {
        _status = status
        _body = body
    }
}

extension CodableResponse: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let body = try _encoder.encode(_body)
        return Response(status: _status, headers: ["Content-Type" : _contentType], body: body)
    }
}
