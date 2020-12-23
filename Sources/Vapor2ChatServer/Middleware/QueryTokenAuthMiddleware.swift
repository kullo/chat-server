/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import Vapor

class QueryTokenAuthMiddleware {
    private let _authTokens: AuthTokenService

    init(authTokens: AuthTokenService) {
        _authTokens = authTokens
    }
}

extension QueryTokenAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard
            let token = request.query?["token"]?.string,
            let tokenData = _authTokens.verifyAndExtractTokenData(token: token, maxAge: 60)
            else { throw Abort(.unauthorized) }

        request.workspace = tokenData.workspace
        request.userID = tokenData.userID
        return try next.respond(to: request)
    }
}

extension Request {
    private static let _workspaceKey = "kullo.workspace"

    var workspace: String {
        get { return storage[Request._workspaceKey] as! String }
        set { storage[Request._workspaceKey] = newValue }
    }
}
