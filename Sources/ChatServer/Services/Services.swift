/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public protocol ServicesProtocol {
    var log: LogService { get }
    var users: UsersService { get }
    var devices: DevicesService { get }
    var conversationPermissions: ConversationPermissionsService { get }
    var conversations: ConversationsService { get }
    var authTokens: AuthTokenService { get }
}

public struct Services: ServicesProtocol {
    public let log: LogService
    public let users: UsersService
    public let devices: DevicesService
    public let conversationPermissions: ConversationPermissionsService
    public let conversations: ConversationsService
    public let authTokens: AuthTokenService

    public init(
        log: LogService,
        users: UsersService,
        devices: DevicesService,
        conversationPermissions: ConversationPermissionsService,
        conversations: ConversationsService,
        authTokens: AuthTokenService) {

        self.log = log
        self.users = users
        self.devices = devices
        self.conversationPermissions = conversationPermissions
        self.conversations = conversations
        self.authTokens = authTokens
    }
}
