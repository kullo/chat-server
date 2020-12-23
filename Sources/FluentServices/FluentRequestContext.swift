/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent

public struct FluentRequestContext: RequestContext {
    public let origin: ObjectIdentifier?
    public let workspace: String
    public let authenticatedUserID: Int?

    public var log: LogService { return _servicesFactory.log }

    private let _transactable: Transactable
    private let _servicesFactory: FluentServicesFactory

    public init(origin: ObjectIdentifier? = nil, workspace: String, userID: Int?, servicesFactory: FluentServicesFactory) {
        self.origin = origin
        self.workspace = workspace
        authenticatedUserID = userID
        _servicesFactory = servicesFactory

        _transactable = Database.default!
    }

    public func transaction<SuccessType: Encodable>(
        _ closure: (ServicesProtocol) -> OperationResult<SuccessType>
        ) -> OperationResult<SuccessType> {

        do {
            return .success(
                try _transactable.transaction({ connection in
                    switch closure(_servicesFactory.makeServices(executor: connection)) {
                    case let .success(success):
                        return success
                    case let .error(error):
                        throw error
                    }
                })
            )
        } catch let error as HandlerError {
            return .error(error)
        } catch {
            return .internalServerError(error, logger: log)
        }
    }

    public func throwingTransaction(_ closure: (ServicesProtocol) throws -> Void) throws {
        try _transactable.transaction({ connection in
            try closure(_servicesFactory.makeServices(executor: connection)) })
    }
}
