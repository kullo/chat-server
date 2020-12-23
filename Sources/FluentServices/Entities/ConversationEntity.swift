/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

final class ConversationEntity: Entity {
    static let idType = IdentifierType.custom("TEXT")

    let storage = Storage()

    let type: ConversationType
    let title: String

    var participants: Siblings<ConversationEntity, UserEntity, Pivot<ConversationEntity, UserEntity>> {
        return siblings()
    }

    init(conversation: Conversation) {
        type = conversation.type
        title = conversation.title

        id = Identifier(conversation.id, in: nil)
    }

    init(row: Row) throws {
        type = ConversationType(rawValue: try row.get("type"))!
        title = try row.get("title")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("type", type.rawValue)
        try row.set("title", title)
        return row
    }
}

extension ConversationEntity: ModelConvertible {
    typealias ModelType = Conversation

    func makeModel() throws -> Conversation {
        return Conversation(
            id: id!.wrapped.string!,
            type: type,
            title: title,
            //TODO: fetching all users just to get their IDs is grossly inefficient
            participantIds: try participants.all().compactMap({ $0.id?.int }))
    }
}
