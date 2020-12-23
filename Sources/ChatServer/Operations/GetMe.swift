/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public struct GetMeResponseBody: Encodable {
    let user: User
    let encryptionPrivkey: String
}

public extension Operation {
    static func getMe(ctx: RequestContext, user: User)
        -> OperationResult<GetMeResponseBody> {

        return .ok(GetMeResponseBody(
            user: user,
            encryptionPrivkey: user.encryptionPrivkey))
    }
}
