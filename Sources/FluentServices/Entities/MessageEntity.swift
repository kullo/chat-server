/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

final class MessageEntity: Entity {
    static let idType = IdentifierType.int

    let storage = Storage()

    let conversationId: String
    let timeSent: Date
    let edited: Bool
    let context: MessageContext
    let encryptedMessage: String

    init(newMessage msg: NewMessage, conversationId: String, timeSent: Date, edited: Bool) {
        self.conversationId = conversationId
        self.timeSent = timeSent
        self.edited = edited
        self.context = msg.context
        self.encryptedMessage = msg.encryptedMessage
    }

    init(row: Row) throws {
        conversationId = try row.get("conversation_id")
        timeSent = try row.get("time_sent")
        edited = try row.get("edited")
        context = try MessageContext(
            version: row.get("ctx_version"),
            parentMessageId: row.get("ctx_parent_message_id") ?? 0,
            previousMessageId: row.get("ctx_previous_message_id") ?? 0,
            conversationKeyId: row.get("ctx_conversation_key_id"),
            deviceKeyId: row.get("ctx_device_key_id"))
        encryptedMessage = try row.get("encrypted_message")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("conversation_id", conversationId)
        try row.set("time_sent", timeSent)
        try row.set("edited", edited)
        try row.set("ctx_version", context.version)
        try row.set("ctx_parent_message_id", nilIfZero(context.parentMessageId))
        try row.set("ctx_previous_message_id", nilIfZero(context.previousMessageId))
        try row.set("ctx_conversation_key_id", context.conversationKeyId)
        try row.set("ctx_device_key_id", context.deviceKeyId)
        try row.set("encrypted_message", encryptedMessage)
        return row
    }
}

extension MessageEntity: ModelConvertible {
    typealias ModelType = Message

    func makeModel() -> Message {
        return Message(
            id: id!.wrapped.int!,
            timeSent: timeSent,
            revision: edited ? 1 : 0,
            context: context,
            encryptedMessage: encryptedMessage)
    }
}

private func nilIfZero(_ val: Int) -> Int? {
    return val == 0 ? nil : val
}
