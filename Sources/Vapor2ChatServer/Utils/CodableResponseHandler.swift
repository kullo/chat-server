/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import HTTP
import Vapor

typealias OperationClosure<SuccessType: Encodable> = (Request, RequestContext) throws -> OperationResult<SuccessType>

struct CodableResponder<SuccessType: Encodable> {
    private let _servicesFactory: ServicesFactory
    private let _operation: OperationClosure<SuccessType>

    init(servicesFactory: ServicesFactory, operation: @escaping OperationClosure<SuccessType>) {
        _servicesFactory = servicesFactory
        _operation = operation
    }
}

extension CodableResponder: Responder {
    func respond(to request: Request) throws -> Response {
        let workspace = try request.parameters.next(String.self)
        let ctx = _servicesFactory.makeRequestContext(workspace: workspace, userID: request.userID)
        switch try _operation(request, ctx) {
        case let .success(result):
            return try CodableResponse(
                status: Status(statusCode: result.status.rawValue), body: result.data
                ).makeResponse()
        case let .error(error):
            throw Abort(Status(statusCode: error.status.rawValue), reason: error.publicDescription)
        }
    }
}

extension RouteBuilder {
    func operation<SuccessType>(
        _ method: HTTP.Method, _ path: String..., servicesFactory: ServicesFactory,
        handler: @escaping OperationClosure<SuccessType>) {

        register(method: method, path: path, responder: CodableResponder(servicesFactory: servicesFactory, operation: handler))
    }
}
