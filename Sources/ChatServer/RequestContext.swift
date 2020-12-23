/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public protocol RequestContext {
    var origin: ObjectIdentifier? { get }
    var workspace: String { get }
    var authenticatedUserID: Int? { get }

    var log: LogService { get }

    func transaction<SuccessType: Encodable>(
        _ closure: (ServicesProtocol) -> OperationResult<SuccessType>)
        -> OperationResult<SuccessType>

    func throwingTransaction(_ closure: (ServicesProtocol) throws -> Void) throws
}
