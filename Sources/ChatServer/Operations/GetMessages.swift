/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getMessages(ctx: RequestContext, convID: Conversation.IDType) -> OperationResult<[Message]> {
        return ctx.transaction({ services in
            switch services.conversations.conversation(id: convID) {
            case let .success(conv):
                guard conv != nil else {
                    return .error(HandlerError(
                        status: .notFound, publicDescription: "Conversation not found"))
                }
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            switch services.conversations.messages(conversationID: convID) {
            case let .success(messages):
                return .ok(messages)
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}
