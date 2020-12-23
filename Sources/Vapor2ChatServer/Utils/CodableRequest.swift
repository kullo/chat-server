/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import Vapor

class CodableRequest<T: Decodable> {
    let body: T

    private let _decoder = CodecFactory.makeJSONDecoder()
    private let _contentType = "application/json"

    init(request: Request, logger: LogService) throws {
        guard request.contentType == _contentType else {
            throw Abort(.unsupportedMediaType)
        }

        switch request.body {
        case let .data(bytes):
            do {
                body = try _decoder.decode(T.self, from: Data(bytes: bytes))
            } catch {
                logger.error("Error decoding body: \(error)")
                throw Abort(.badRequest, reason: "Body could not be decoded")
            }
        case .chunked:
            throw Abort(.badRequest)
        }
    }
}
