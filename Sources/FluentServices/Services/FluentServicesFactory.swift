/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import RxSwift

public class FluentServicesFactory: ServicesFactory {
    public let conversationsEventSubject = PublishSubject<ConversationsEvent>()
    public let permissionsEventSubject = PublishSubject<ConversationPermissionsEvent>()

    public let log: LogService
    public let authTokens: AuthTokenService

    public init(logger: LogService, authTokens: AuthTokenService) {
        self.log = logger
        self.authTokens = authTokens
    }

    public func makeReadingUsers() -> ReadingUsersService {
        return FluentUsersService(Database.default!)
    }

    public func makeReadingDevices() -> ReadingDevicesService {
        return FluentDevicesService(Database.default!)
    }

    public func makeRequestContext(
        origin: ObjectIdentifier? = nil, workspace: String, userID: Int? = nil) -> RequestContext {
        return FluentRequestContext(
            origin: origin, workspace: workspace, userID: userID, servicesFactory: self)
    }

    public func makeServices(executor: Executor) -> ServicesProtocol {
        return Services(
            log: log,
            users: FluentUsersService(executor),
            devices: FluentDevicesService(executor),
            conversationPermissions: FluentConversationPermissionsService(
                executor, eventSubject: permissionsEventSubject),
            conversations: FluentConversationsService(
                executor, eventSubject: conversationsEventSubject),
            authTokens: authTokens)
    }
}
