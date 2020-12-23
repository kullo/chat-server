/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getUsers(ctx: RequestContext, state rawState: String?) -> OperationResult<[User]> {
        return ctx.transaction({ services in
            let users: ServiceResult<[User]>
            if let rawState = rawState {
                guard let state = User.State(rawValue: rawState) else {
                    return .error(HandlerError(
                        status: .unprocessableEntity,
                        publicDescription: "Unknown state: \(rawState)"))
                }
                users = services.users.withState(state)
            } else {
                users = services.users.all()
            }

            switch users {
            case let .success(users):
                return .ok(users)
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}
