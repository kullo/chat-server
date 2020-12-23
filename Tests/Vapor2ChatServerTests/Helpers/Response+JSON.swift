/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation
import HTTP

extension Response {
    func getJSONBody() throws -> Any {
        guard let bodyBytes = body.bytes else { throw TestError.invalidBodyType }
        return try JSONSerialization.jsonObject(with: Data(bytes: bodyBytes), options: [])
    }
}
