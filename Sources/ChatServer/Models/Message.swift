/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct Message: Codable {
    public let id: Int
    public let timeSent: Date
    public let revision: Int
    public let context: MessageContext
    public let encryptedMessage: String

    public init(id: Int, timeSent: Date, revision: Int, context: MessageContext, encryptedMessage: String) {
        self.id = id
        self.timeSent = timeSent
        self.revision = revision
        self.context = context
        self.encryptedMessage = encryptedMessage
    }

    public static func fromNewMessage(_ msg: NewMessage, id: Int, timeSent: Date, revision: Int) -> Message {
        return Message(
            id: id,
            timeSent: timeSent,
            revision: revision,
            context: msg.context,
            encryptedMessage: msg.encryptedMessage)
    }
}

public struct NewMessage: Codable {
    public let context: MessageContext
    public let encryptedMessage: String

    public init(context: MessageContext, encryptedMessage: String) {
        self.context = context
        self.encryptedMessage = encryptedMessage
    }
}

public struct MessageContext: Codable, Equatable {
    public let version: Int
    public let parentMessageId: Int
    public let previousMessageId: Int
    public let conversationKeyId: String
    public let deviceKeyId: String

    public init(version: Int, parentMessageId: Int, previousMessageId: Int, conversationKeyId: String, deviceKeyId: String) {
        self.version = version
        self.parentMessageId = parentMessageId
        self.previousMessageId = previousMessageId
        self.conversationKeyId = conversationKeyId
        self.deviceKeyId = deviceKeyId
    }
}
