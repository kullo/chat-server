/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public struct NewUserResponseBody: Encodable {
    let verificationCode: String
    let user: User
}

public extension Operation {
    static func addUser(
        ctx: RequestContext, newUser: NewUser
        ) -> OperationResult<NewUserResponseBody> {

        return ctx.transaction({ services in
            switch services.users.addUser(newUser) {
            case let .success(user):
                return .ok(NewUserResponseBody(
                    verificationCode: "music pear battery t-shirt", user: user))
            case let .error(error):
                return .error(HandlerError(status: .conflict, publicDescription: error.publicDescription))
            }
        })
    }
}
