/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func addMessage(ctx: RequestContext, newMessage: NewMessage) -> OperationResult<Message> {
        return ctx.transaction({ services in
            let permission: ConversationPermission
            switch services.conversationPermissions.permission(
                forKey: newMessage.context.conversationKeyId, userID: ctx.authenticatedUserID!) {
            case let .success(thePermission):
                guard let thePermission = thePermission else {
                    return .error(HandlerError(
                        status: .notFound, publicDescription: "Permission not found"))
                }
                permission = thePermission
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            let conversation: Conversation
            switch services.conversations.conversation(id: permission.conversationId) {
            case let .success(theConversation):
                guard let theConversation = theConversation else {
                    return .error(HandlerError(
                        status: .notFound, publicDescription: "Conversation not found"))
                }
                conversation = theConversation
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            switch services.conversationPermissions.isLatestForConversation(permission: permission) {
            case let .success(isLatest):
                guard isLatest else {
                    return .error(HandlerError(
                        status: .conflict, publicDescription: "Obsolete conversation key"))
                }
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            let device: Device
            switch services.devices.withID(newMessage.context.deviceKeyId) {
            case let .success(theDevice):
                guard let theDevice = theDevice else {
                    return .error(HandlerError(status: .notFound, publicDescription: "Device not found"))
                }
                device = theDevice
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            guard
                device.state == .active && device.ownerId == ctx.authenticatedUserID! else {
                    return .error(HandlerError(status: .notFound, publicDescription: "Device not found"))
            }

            let result = services.conversations.addMessage(
                newMessage,
                conversationID: conversation.id,
                origin: ctx.origin)

            switch result {
            case let .success(message):
                return .ok(message)

            case let .error(error):
                switch error as? ConversationsError {
                case .some(.wrongParentMessageID),
                     .some(.wrongPreviousMessageID),
                     .some(.noPreviousMessage):
                    return .error(HandlerError(
                        status: .unprocessableEntity, publicDescription: error.publicDescription))
                default:
                    return .internalServerError(error, logger: ctx.log)
                }
            }
        })
    }
}
