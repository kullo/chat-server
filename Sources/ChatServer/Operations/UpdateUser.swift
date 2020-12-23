/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public extension Operation {
    static func updateUser(
        ctx: RequestContext, userID: Int, update: UserUpdate, permissions: [ConversationPermission]
        ) -> OperationResult<Empty> {

        return ctx.transaction({ services in
            switch services.users.update(id: userID, with: update) {
            case .success:
                switch services.conversationPermissions.add(permissions: permissions, origin: ctx.origin) {
                case .success:
                    return .noContent
                case let .error(error):
                    return .error(HandlerError(
                        status: .conflict, publicDescription: error.publicDescription))
                }
            case let .error(error):
                return .error(HandlerError(
                    status: .notFound, publicDescription: error.publicDescription))
            }
        })
    }
}
