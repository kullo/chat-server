/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func addConversation(
        ctx: RequestContext, conversation: Conversation, permissions: [ConversationPermission]
        ) -> OperationResult<Empty> {
        return ctx.transaction({ services in
            if conversation.participantIds.contains(where: { services.users.withID($0).successValue == .some(nil) }) {
                return .error(HandlerError(
                    status: .unprocessableEntity, publicDescription: "Participant not found"))
            }

            switch services.conversations.addConversation(conversation, origin: ctx.origin) {
            case let .success(conv):
                switch services.conversationPermissions.add(permissions: permissions, convID: conv.id, origin: ctx.origin) {
                case .success:
                    return .noContent
                case let .error(error):
                    return .error(HandlerError(
                        status: .conflict, publicDescription: error.publicDescription))
                }
            case let .error(error):
                return .error(HandlerError(
                    status: .conflict, publicDescription: error.publicDescription))
            }
        })
    }
}
