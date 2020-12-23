/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation

struct WebSocketRequest<T: Decodable>: Decodable {
    let id: Int
    let data: T
}

protocol WebSocketRequestHandlerProtocol {
    func makeResponse(
        connection: WebSocketConnectionMeta, requestBody: Data, servicesFactory: ServicesFactory
        ) throws -> Data
}

struct WebSocketRequestHandler<RequestType: Decodable, SuccessType: Encodable>
    : WebSocketRequestHandlerProtocol {

    let requestType: RequestType.Type
    let operation: (WebSocketConnectionMeta, WebSocketRequest<RequestType>, RequestContext)
    -> OperationResult<SuccessType>

    func makeResponse(
        connection: WebSocketConnectionMeta, requestBody: Data, servicesFactory: ServicesFactory
        ) throws -> Data {

        let decoder = CodecFactory.makeJSONDecoder()
        let request = try decoder.decode(WebSocketRequest<RequestType>.self, from: requestBody)
        let ctx = servicesFactory.makeRequestContext(
            origin: connection.id,
            workspace: connection.workspace,
            userID: connection.userID)

        switch operation(connection, request, ctx) {
        case let .success(result):
            let meta = ResponseMeta(requestID: request.id)
            let response = ResponseEvent(meta: meta, data: result.data)
            return try CodecFactory.makeJSONEncoder().encode(response)
        case let .error(error):
            throw error
        }
    }
}
