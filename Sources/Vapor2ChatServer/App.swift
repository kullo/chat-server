/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Vapor

public final class App {
    public static func setup(config: Config) throws {
        config.addConfigurable(log: ConsolePlainLogger.init, name: "console-plain")
    }

    public static func setup(droplet drop: Droplet, servicesFactory: ServicesFactory) throws {
        // override default behavior, which is only .error and fatal
        if drop.config.environment == .production {
            drop.log.enabled = [.info, .warning, .error, .fatal]
            drop.log.info("Re-enabled informational and warning logs")
        }

        for collection in makeRouteCollections(servicesFactory: servicesFactory) {
            try collection.build(drop)
        }
    }

    static func makeRouteCollections(servicesFactory: ServicesFactory) -> [RouteCollection] {
        let webSocketController = WebSocketController<WebSocket>(
            servicesFactory: servicesFactory,
            requestHandlers: webSocketRequestHandlers,
            events: webSocketEvents(for: servicesFactory))

        let headerAuth = HeaderAuthMiddleware(users: servicesFactory.makeReadingUsers(), devices: servicesFactory.makeReadingDevices(), logger: servicesFactory.log)
        let pvkAuth = PasswordVerificationKeyAuthMiddleware(users: servicesFactory.makeReadingUsers(), logger: servicesFactory.log)
        let queryAuth = QueryTokenAuthMiddleware(authTokens: servicesFactory.authTokens)

        return [
            UsersRoutes(headerAuth: headerAuth, pvkAuth: pvkAuth, servicesFactory: servicesFactory),
            DevicesRoutes(headerAuth: headerAuth, pvkAuth: pvkAuth, servicesFactory: servicesFactory),
            ConversationsRoutes(headerAuth: headerAuth, servicesFactory: servicesFactory),
            BlobRoutes(),
            WebSocketRoutes(headerAuth: headerAuth, queryAuth: queryAuth, servicesFactory: servicesFactory, controller: webSocketController),
        ]
    }
}
