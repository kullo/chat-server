/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Vapor

private struct UpdateUserRequestBody: Decodable {
    let user: UserUpdate
    let permissions: [ConversationPermission]?
}

class UsersRoutes: RouteCollection {
    private let _headerAuthMiddleware: HeaderAuthMiddleware
    private let _pvkAuthMiddleware: PasswordVerificationKeyAuthMiddleware
    private let _servicesFactory: ServicesFactory

    init(
        headerAuth: HeaderAuthMiddleware,
        pvkAuth: PasswordVerificationKeyAuthMiddleware,
        servicesFactory: ServicesFactory) {

        _headerAuthMiddleware = headerAuth
        _pvkAuthMiddleware = pvkAuth
        _servicesFactory = servicesFactory
    }

    func build(_ builder: RouteBuilder) throws {
        let users = builder.grouped("v1", String.parameter, "users")
        let headerAuthenticated = users.grouped(_headerAuthMiddleware)

        users.operation(.post, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<NewUserResponseBody> in
            let requestBody = try CodableRequest<NewUser>(
                request: req, logger: ctx.log).body
            return Operation.addUser(ctx: ctx, newUser: requestBody)
        }

        headerAuthenticated.operation(.get, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<ListResult<User, Empty>> in
            let state = req.query?["state"]?.string
            return Operation.getUsers(ctx: ctx, state: state).map({
                ListResult(
                    objects: $0,
                    related: Empty(),
                    meta: ListMeta(nextCursor: nil))
            })
        }

        headerAuthenticated.operation(.patch, Int.parameter, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<Empty> in
            let userID = try req.parameters.next(Int.self)
            let requestBody = try CodableRequest<UpdateUserRequestBody>(request: req, logger: ctx.log).body
            return Operation.updateUser(
                ctx: ctx, userID: userID,
                update: requestBody.user, permissions: requestBody.permissions ?? [])
        }

        users.grouped(_pvkAuthMiddleware).operation(.post, "get_me", servicesFactory: _servicesFactory) { req, ctx in
            Operation.getMe(ctx: ctx, user: req.user!)
        }
    }
}
