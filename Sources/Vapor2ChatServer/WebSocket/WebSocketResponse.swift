/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer

struct ResponseEvent<T: Encodable>: Encodable {
    let type = "response"
    let meta: ResponseMeta?
    let data: T?
}

extension ResponseEvent where T == Empty {
    static func makeError(requestID: Int, error: Error) -> ResponseEvent<T> {
        let errorMessage: String
        if let error = error as? PubliclyDescribable {
            errorMessage = error.publicDescription
        } else {
            // Due to the possibility of leaking sensitive data in the full error description, only
            // send the type of error (e.g. "DecodingError").
            errorMessage = String(reflecting: Swift.type(of: error))
        }
        return ResponseEvent<Empty>(
            meta: ResponseMeta(requestID: requestID, error: errorMessage),
            data: nil)
    }
}

struct ResponseMeta: Encodable {
    let requestId: Int
    let error: String?

    init(requestID: Int, error: String? = nil) {
        self.requestId = requestID
        self.error = error
    }
}
