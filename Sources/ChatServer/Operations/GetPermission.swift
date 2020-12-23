/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getPermission(ctx: RequestContext, convKeyID: String) -> OperationResult<ConversationPermission> {
        return ctx.transaction({ services in
            let result = services.conversationPermissions
                .permission(forKey: convKeyID, userID: ctx.authenticatedUserID!)

            switch result {
            case let .success(permission):
                guard let permission = permission else {
                    return .error(HandlerError(status: .notFound, publicDescription: "Permission not found"))
                }
                return .ok(permission)
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}
