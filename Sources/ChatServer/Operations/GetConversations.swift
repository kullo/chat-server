/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getConversations(ctx: RequestContext) -> OperationResult<ConversationsAndPermissions> {

        return ctx.transaction({ services in
            let conversations: [Conversation]
            switch services.conversations.all() {
            case let .success(theConversations):
                conversations = theConversations
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            let convIDs = conversations.map({ $0.id })

            switch services.conversationPermissions.permissions(forOwner: ctx.authenticatedUserID!) {
            case let .success(permissionsByConversation):
                let permissions = permissionsByConversation
                    .filter({ convIDs.contains($0.key) }).values.flatMap({ $0 })
                return .ok(ConversationsAndPermissions(conversations: conversations, permissions: permissions))
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}

public struct ConversationsAndPermissions: Codable {
    public let conversations: [Conversation]
    public let permissions: [ConversationPermission]
}
