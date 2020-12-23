/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import RxSwift

public protocol ServicesFactory {
    var conversationsEventSubject: PublishSubject<ConversationsEvent> { get }
    var permissionsEventSubject: PublishSubject<ConversationPermissionsEvent> { get }

    var log: LogService { get }
    var authTokens: AuthTokenService { get }

    func makeReadingUsers() -> ReadingUsersService
    func makeReadingDevices() -> ReadingDevicesService

    func makeRequestContext(origin: ObjectIdentifier?, workspace: String, userID: Int?) -> RequestContext
}

public extension ServicesFactory {
    func makeRequestContext(workspace: String, userID: Int?) -> RequestContext {
        return makeRequestContext(origin: nil, workspace: workspace, userID: userID)
    }
}
