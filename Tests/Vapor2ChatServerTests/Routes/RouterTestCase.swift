/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent
import Routing
import Testing
import XCTest

@testable import ChatServer
@testable import ChatServerTesting
@testable import FluentServices
@testable import Vapor2ChatServer

/// sourcery: disableTests
class RouterTestCase: XCTestCase {
    private(set) var servicesFactory: ServicesFactory!
    private(set) var services: ServicesProtocol!
    private(set) var router: Router!
    let logger = LogServiceStub()

    override func setUp() {
        super.setUp()
        Testing.onFail = XCTFail

        try! FluentServices.setup(deleteAllData: true)
        FluentServicesTesting.addUsers(makeUsers())
        FluentServicesTesting.addDevices(makeDevices())
        FluentServicesTesting.addConversations(makeConversations())
        FluentServicesTesting.addPermissions(makePermissions())
        FluentServicesTesting.addMessages(makeMessages())

        let fluentServicesFactory = FluentServicesFactory(logger: logger, authTokens: AuthTokenManager())
        servicesFactory = fluentServicesFactory
        services = fluentServicesFactory.makeServices(executor: Database.default!)

        let collections = App.makeRouteCollections(servicesFactory: servicesFactory)

        router = Router()
        for collection in collections {
            try! collection.build(router)
        }
    }

    func makeUsers() -> [(NewUser, User.State)] {
        return TestData.users
    }

    func makeDevices() -> [Device] {
        return TestData.devices
    }

    func makeConversations() -> [Conversation] {
        return TestData.conversations
    }

    func makePermissions() -> [Conversation.IDType: [ConversationPermission]] {
        return TestData.permissions
    }

    func makeMessages() -> [Conversation.IDType: [NewMessage]] {
        return [:]
    }

    func makeWebSocketController() -> WebSocketController<WebSocketFake> {
        return WebSocketController<WebSocketFake>(
            servicesFactory: servicesFactory,
            requestHandlers: App.webSocketRequestHandlers,
            events: App.webSocketEvents(for: servicesFactory))
    }
}
