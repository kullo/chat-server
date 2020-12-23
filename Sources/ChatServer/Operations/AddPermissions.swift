/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func addPermissions(
        ctx: RequestContext, convID: Conversation.IDType, permissions: [ConversationPermission]
        ) -> OperationResult<Empty> {

        return ctx.transaction({ services in
            guard case let .success(conv) = services.conversations.conversation(id: convID), conv != nil else {
                return .error(HandlerError(
                    status: .notFound,
                    publicDescription: "Conversation not found"))
            }

            if permissions.contains(where: { $0.creatorId != ctx.authenticatedUserID }) {
                return .error(HandlerError(
                    status: .unprocessableEntity,
                    publicDescription: "Authenticated user must be the creator"))
            }

            if permissions.contains(where: { services.users.withID($0.ownerId).successValue == .some(nil) }) {
                return .error(HandlerError(
                    status: .unprocessableEntity,
                    publicDescription: "Owner must exist"))
            }

            switch services.conversationPermissions.add(permissions: permissions, convID: convID, origin: ctx.origin) {
            case .success:
                return .noContent
            case let .error(error):
                return .error(HandlerError(status: .conflict, publicDescription: error.publicDescription))
            }
        })
    }
}
