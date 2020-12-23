/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct AnyEncodable: Encodable {
    private let _wrapped: Encodable

    public init(_ wrapped: Encodable) {
        _wrapped = wrapped
    }

    public func encode(to encoder: Encoder) throws {
        try _wrapped.encode(to: encoder)
    }
}
