/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import RxSwift

public class FluentConversationsService {
    private let _executor: Executor
    private let _changeSubject: PublishSubject<ConversationsEvent>

    public init(_ executor: Executor, eventSubject: PublishSubject<ConversationsEvent>) {
        _executor = executor
        _changeSubject = eventSubject
    }
}

extension FluentConversationsService: ConversationsService {
    public var changeObservable: Observable<ConversationsEvent> {
        return _changeSubject.asObservable()
    }

    public func all() -> ServiceResult<[Conversation]> {
        return ConversationEntity.getMultiple(filter: { try $0.all() })
    }

    public func conversation(id: Conversation.IDType) -> ServiceResult<Conversation?> {
        return ConversationEntity.getOne(filter: { try $0.find(id) })
    }

    public func addConversation(_ conversation: Conversation, origin: ObjectIdentifier?) -> ServiceResult<Conversation> {
        do {
            switch conversation.type {
            case .channel:
                guard try ConversationEntity.makeQuery()
                    .filter("type", ConversationType.channel.rawValue)
                    .filter("title", conversation.title)
                    .count() == 0 else {
                    return .error(ConversationsError.conflictingName)
                }
            case .group:
                let allGroups = try ConversationEntity.makeQuery().filter("type", ConversationType.group.rawValue).all()
                for group in allGroups {
                    let participantIDs = try group.participants.all().map({ $0.id!.int! })
                    guard participantIDs.sorted() != conversation.participantIds.sorted() else {
                        return .error(ConversationsError.conflictingParticipants)
                    }
                }
            }

            let participants = try UserEntity.makeQuery()
                .filter("id", in: conversation.participantIds)
                .all()

            let entity = ConversationEntity(conversation: conversation)
            try entity.save()
            for participant in participants {
                try entity.participants.add(participant)
            }

            _changeSubject.onNext(
                ConversationsEvent(
                    origin: origin,
                    type: .added(conversation: conversation)))
            return .success(conversation)

        } catch {
            if FluentErrorUtil.isConstraintViolation(error: error, column: "id") {
                return .error(ConversationsError.conflictingID)
            } else {
                var serviceError = FluentServiceError.generalDatabaseError
                serviceError.reason = error
                return .error(serviceError)
            }
        }
    }

    public func join(convID: Conversation.IDType, userID: Int, origin: ObjectIdentifier?) -> ServiceResult<Conversation> {
        do {
            guard
                let conversation = try ConversationEntity.makeQuery().find(convID),
                let user = try UserEntity.makeQuery().find(userID)
            else {
                return .error(ConversationsError.notFound)
            }

            if try !conversation.participants.isAttached(user) {
                try conversation.participants.add(user)
                _changeSubject.onNext(
                    ConversationsEvent(
                        origin: origin,
                        type: .updated(conversation: try conversation.makeModel())))
            }
            return .success(try conversation.makeModel())

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }

    public func leave(convID: Conversation.IDType, userID: Int, origin: ObjectIdentifier?) -> ServiceResult<Conversation> {
        do {
            guard let conversation = try ConversationEntity.makeQuery().find(convID) else {
                return .error(ConversationsError.notFound)
            }

            if let user = try conversation.participants.find(userID) {
                try conversation.participants.remove(user)
                _changeSubject.onNext(
                    ConversationsEvent(
                        origin: origin,
                        type: .updated(conversation: try conversation.makeModel())))
            }
            return .success(try conversation.makeModel())

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }

    public func messages(conversationID: Conversation.IDType) -> ServiceResult<[Message]> {
        return MessageEntity.getMultiple(
            filter: { try $0.filter("conversation_id", conversationID).all() })
    }

    public func addMessage(_ newMessage: NewMessage, conversationID: Conversation.IDType, origin: ObjectIdentifier?) -> ServiceResult<Message> {

        do {
            let parentMessageID = newMessage.context.parentMessageId
            if parentMessageID != 0 {
                guard try MessageEntity.makeQuery()
                    .filter("id", parentMessageID)
                    .filter("conversation_id", conversationID)
                    .count() == 1 else {
                        return .error(ConversationsError.wrongParentMessageID)
                }
            }

            let previousMessageID = newMessage.context.previousMessageId
            let previousMessage = try MessageEntity.makeQuery()
                .filter("ctx_parent_message_id", parentMessageID == 0 ? nil : parentMessageID)
                .sort("id", .descending)
                .first()
            if let previousMessage = previousMessage {
                guard previousMessageID == previousMessage.id!.int! else {
                    return .error(ConversationsError.wrongPreviousMessageID)
                }
            } else {
                guard previousMessageID == 0 else {
                    return .error(ConversationsError.noPreviousMessage)
                }
            }

            let entity = MessageEntity(
                newMessage: newMessage, conversationId: conversationID,
                timeSent: Date(), edited: false)
            try entity.save()
            let message = entity.makeModel()

            _changeSubject.onNext(
                ConversationsEvent(
                    origin: origin,
                    type: .messageAdded(conversationID: conversationID, message: message)))
            return .success(message)

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }
}
