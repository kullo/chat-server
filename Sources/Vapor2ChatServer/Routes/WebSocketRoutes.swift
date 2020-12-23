/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Vapor

class WebSocketRoutes: RouteCollection {
    private let _headerAuthMiddleware: HeaderAuthMiddleware
    private let _queryAuthMiddleware: QueryTokenAuthMiddleware
    private let _servicesFactory: ServicesFactory
    private let _controller: WebSocketController<WebSocket>

    init(headerAuth: HeaderAuthMiddleware,
         queryAuth: QueryTokenAuthMiddleware,
         servicesFactory: ServicesFactory,
         controller: WebSocketController<WebSocket>) {

        _headerAuthMiddleware = headerAuth
        _queryAuthMiddleware = queryAuth
        _servicesFactory = servicesFactory
        _controller = controller
    }

    func build(_ builder: RouteBuilder) throws {
        builder.grouped(_headerAuthMiddleware).grouped("v1", String.parameter)
            .operation(.post, "ws_urls", servicesFactory: _servicesFactory) { req, ctx in
            Operation.makeWebSocketURL(ctx: ctx, baseURL: req.baseURL(baseScheme: "ws"))
        }

        builder.grouped(_queryAuthMiddleware).socket("ws", handler: _controller.handleConnection)
    }
}
