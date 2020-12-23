/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation
import RxSwift

public struct ConversationsEvent {
    public enum EventType {
        case added(conversation: Conversation)
        case updated(conversation: Conversation)
        case messageAdded(conversationID: Conversation.IDType, message: Message)
    }

    public let origin: ObjectIdentifier?
    public let type: EventType

    public init(origin: ObjectIdentifier?, type: EventType) {
        self.origin = origin
        self.type = type
    }
}

public protocol ConversationsService {
    var changeObservable: Observable<ConversationsEvent> { get }

    func addConversation(_ conversation: Conversation, origin: ObjectIdentifier?) -> ServiceResult<Conversation>
    func all() -> ServiceResult<[Conversation]>
    func conversation(id: Conversation.IDType) -> ServiceResult<Conversation?>

    func join(convID: Conversation.IDType, userID: Int, origin: ObjectIdentifier?) -> ServiceResult<Conversation>
    func leave(convID: Conversation.IDType, userID: Int, origin: ObjectIdentifier?) -> ServiceResult<Conversation>

    func messages(conversationID: Conversation.IDType) -> ServiceResult<[Message]>
    func addMessage(
        _ newMessage: NewMessage,
        conversationID: Conversation.IDType,
        origin: ObjectIdentifier?) -> ServiceResult<Message>
}

public enum ConversationsError: String, Error, PubliclyDescribable {
    public var publicDescription: String { return rawValue }

    case conflictingID = "Conversation with the same ID does already exist"
    case conflictingParticipants = "Group with the same participants does already exist"
    case conflictingName = "Channel with the same name does already exist"
    case notFound = "Conversation not found"
    case wrongParentMessageID = "Wrong parentMessageId"
    case wrongPreviousMessageID = "Wrong previousMessageId"
    case noPreviousMessage = "previousMessageId != 0 but no previous message exists"
}
