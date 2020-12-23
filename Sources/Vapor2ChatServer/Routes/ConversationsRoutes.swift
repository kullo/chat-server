/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Vapor

private struct CreateConversationRequestBody: Decodable {
    let conversation: Conversation
    let permissions: [ConversationPermission]
}

class ConversationsRoutes: RouteCollection {
    private let _headerAuthMiddleware: HeaderAuthMiddleware
    private let _servicesFactory: ServicesFactory

    init(headerAuth: HeaderAuthMiddleware, servicesFactory: ServicesFactory) {
        _headerAuthMiddleware = headerAuth
        _servicesFactory = servicesFactory
    }

    func build(_ builder: RouteBuilder) throws {
        let conversations = builder
            .grouped(_headerAuthMiddleware)
            .grouped("v1", String.parameter, "conversations")

        conversations.operation(.post, servicesFactory: _servicesFactory) { req, ctx -> OperationResult<Empty> in
            let requestBody = try CodableRequest<CreateConversationRequestBody>(
                request: req, logger: ctx.log).body
            return Operation.addConversation(
                ctx: ctx,
                conversation: requestBody.conversation,
                permissions: requestBody.permissions)
        }

        conversations.operation(.post, Conversation.IDType.parameter, "permissions", servicesFactory: _servicesFactory) {
            req, ctx -> OperationResult<Empty> in
            let requestBody = try CodableRequest<[ConversationPermission]>(
                request: req, logger: ctx.log).body
            return Operation.addPermissions(
                ctx: ctx,
                convID: try req.parameters.next(Conversation.IDType.self),
                permissions: requestBody)
        }

        conversations.operation(.get, servicesFactory: _servicesFactory) { _, ctx in
            Operation.getConversations(ctx: ctx).map({
                ListResult(
                    objects: $0.conversations,
                    related: ConversationsRelated(permissions: $0.permissions),
                    meta: ListMeta(nextCursor: nil))
            })
        }

        conversations.operation(.get, Conversation.IDType.parameter, "messages", servicesFactory: _servicesFactory) { req, ctx in
            Operation.getMessages(ctx: ctx, convID: try req.parameters.next(Conversation.IDType.self)).map({
                ListResult(
                    objects: $0,
                    related: Empty(),
                    meta: ListMeta(nextCursor: nil))
            })
        }
    }
}

private struct ConversationsRelated: Encodable {
    let permissions: [ConversationPermission]
}
