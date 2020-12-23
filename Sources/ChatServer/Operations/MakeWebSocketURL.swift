/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct NewWebSocketURLResult: Encodable {
    let socketUrl: String
}

public extension Operation {
    static func makeWebSocketURL(
        ctx: RequestContext, baseURL: URLComponents
        ) -> OperationResult<NewWebSocketURLResult> {

        return ctx.transaction({ services in
            let token = services.authTokens.make(
                workspace: ctx.workspace, userID: ctx.authenticatedUserID!)

            var baseURLWithQuery = baseURL
            baseURLWithQuery.queryItems = [URLQueryItem(name: "token", value: token)]
            guard let socketURL = baseURLWithQuery.url?.appendingPathComponent("ws") else {
                return .error(HandlerError(
                    status: .internalServerError, publicDescription: "Invalid base URL"))
            }
            return .ok(NewWebSocketURLResult(socketUrl: socketURL.absoluteString))
        })
    }
}
