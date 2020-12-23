/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func joinConversation(
        ctx: RequestContext, convID: Conversation.IDType
        ) -> OperationResult<Conversation> {

        return ctx.transaction({ services in
            let result = services.conversations.join(
                convID: convID,
                userID: ctx.authenticatedUserID!,
                origin: ctx.origin)
            return handleJoinOrLeaveResult(result, logger: ctx.log)
        })
    }

    static func leaveConversation(
        ctx: RequestContext, convID: Conversation.IDType
        ) -> OperationResult<Conversation> {

        return ctx.transaction({ services in
            let result = services.conversations.leave(
                convID: convID,
                userID: ctx.authenticatedUserID!,
                origin: ctx.origin)
            return handleJoinOrLeaveResult(result, logger: ctx.log)
        })
    }

    private static func handleJoinOrLeaveResult(
        _ result: ServiceResult<Conversation>, logger: LogService) -> OperationResult<Conversation> {

        switch result {
        case let .success(conversation):
            return .ok(conversation)

        case let .error(error):
            switch error as? ConversationsError {
            case .some(.notFound):
                return .error(HandlerError(
                    status: .notFound,
                    publicDescription: error.publicDescription))
            default:
                return .internalServerError(error, logger: logger)
            }
        }
    }
}
