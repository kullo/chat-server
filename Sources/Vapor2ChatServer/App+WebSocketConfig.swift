/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import RxSwift

extension App {
    static let webSocketRequestHandlers: [String: WebSocketRequestHandlerProtocol] = [
        "message.add": WebSocketRequestHandler(
            requestType: NewMessage.self,
            operation: { conn, req, ctx in
                Operation.addMessage(ctx: ctx, newMessage: req.data)
        }),
        "device.get": WebSocketRequestHandler(
            requestType: DeviceIdentifier.self,
            operation: { _, req, ctx in
                Operation.getDevice(ctx: ctx, deviceID: req.data.id)
        }),
        "user.get": WebSocketRequestHandler(
            requestType: UserIdentifier.self,
            operation: { _, req, ctx in
                Operation.getUser(ctx: ctx, userID: req.data.id)
        }),
        "conversation.join": WebSocketRequestHandler(
            requestType: ConversationIdentifier.self,
            operation: { _, req, ctx in
                Operation.joinConversation(ctx: ctx, convID: req.data.id)
        }),
        "conversation.leave": WebSocketRequestHandler(
            requestType: ConversationIdentifier.self,
            operation: { _, req, ctx in
                Operation.leaveConversation(ctx: ctx, convID: req.data.id)
        }),
        "conversation_permission.get": WebSocketRequestHandler(
            requestType: ConversationKeyIdentifier.self,
            operation: { _, req, ctx in
                Operation.getPermission(ctx: ctx, convKeyID: req.data.conversationKeyId)
        }),
        "attachments.add": WebSocketRequestHandler(
            requestType: NewAttachments.self,
            operation: { conn, req, ctx in
                Operation.addAttachments(ctx: ctx, newAttachments: req.data, baseURL: conn.baseURL)
        })
    ]

    static func webSocketEvents(for servicesFactory: ServicesFactory) -> Observable<WebSocketEvent> {
        return Observable.of(
            servicesFactory.conversationsEventSubject.map({ event in
                switch event.type {
                case let .added(conversation):
                    return WebSocketEvent(
                        recipientUserIDs: nil,
                        type: "conversation.added",
                        body: AnyEncodable(conversation),
                        origin: event.origin)
                case let .updated(conversation):
                    return WebSocketEvent(
                        recipientUserIDs: nil,
                        type: "conversation.updated",
                        body: AnyEncodable(conversation),
                        origin: event.origin)
                case let .messageAdded(_, message):
                    return WebSocketEvent(
                        recipientUserIDs: nil,
                        type: "message.added",
                        body: AnyEncodable(message),
                        origin: event.origin)
                }
            }),
            servicesFactory.permissionsEventSubject.map({ event in
                switch event.type {
                case let .added(permission):
                    return WebSocketEvent(
                        recipientUserIDs: Set([permission.ownerId]),
                        type: "conversation_permission.added",
                        body: AnyEncodable(permission),
                        origin: event.origin)
                }
            })
        ).merge()
    }
}
