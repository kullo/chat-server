/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import Vapor

struct EmailAndPVK: Decodable {
    let email: String
    let passwordVerificationKey: String
}

class PasswordVerificationKeyAuthMiddleware {
    private let _users: ReadingUsersService
    private let _log: LogService

    init(users: ReadingUsersService, logger: LogService) {
        _users = users
        _log = logger
    }
}

extension PasswordVerificationKeyAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let requestBody = try CodableRequest<EmailAndPVK>(
            request: request, logger: _log).body

        switch _users.withEmail(requestBody.email) {
        case let .success(user):
            guard let user = user,
                user.passwordVerificationKey == requestBody.passwordVerificationKey else {
                throw Abort(.unauthorized)
            }
            request.userID = user.id
            request.user = user
            return try next.respond(to: request)

        case let .error(error):
            _log.error("While authenticating with PVK: \(error)")
            throw Abort(.internalServerError)
        }
    }
}
