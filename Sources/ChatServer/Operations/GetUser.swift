/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getUser(ctx: RequestContext, userID: Int) -> OperationResult<User> {
        return ctx.transaction({ services in
            switch services.users.withID(userID) {
            case let .success(user):
                guard let user = user else {
                    return .error(HandlerError(status: .notFound, publicDescription: "User not found"))
                }
                return .ok(user)
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}
