/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

final class ConversationPermissionEntity: Entity {
    let storage = Storage()

    let conversationId: String
    let creatorId: Int
    let ownerId: Int
    let validFrom: DateString
    let conversationKeyId: String
    let conversationKey: String
    let signature: String

    init(permission: ConversationPermission) {
        conversationId = permission.conversationId
        creatorId = permission.creatorId
        ownerId = permission.ownerId
        validFrom = permission.validFrom
        conversationKeyId = permission.conversationKeyId
        conversationKey = permission.conversationKey
        signature = permission.signature
    }

    init(row: Row) throws {
        conversationId = try row.get("conversation_id")
        creatorId = try row.get("creator_id")
        ownerId = try row.get("owner_id")
        validFrom = DateString(rfc3339String: try row.get("valid_from"))!
        conversationKeyId = try row.get("conversation_key_id")
        conversationKey = try row.get("conversation_key")
        signature = try row.get("signature")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("conversation_id", conversationId)
        try row.set("creator_id", creatorId)
        try row.set("owner_id", ownerId)
        try row.set("valid_from", validFrom.string)
        try row.set("conversation_key_id", conversationKeyId)
        try row.set("conversation_key", conversationKey)
        try row.set("signature", signature)
        return row
    }
}

extension ConversationPermissionEntity: ModelConvertible {
    typealias ModelType = ConversationPermission

    func makeModel() throws -> ConversationPermission {
        return ConversationPermission(
            conversationId: conversationId,
            creatorId: creatorId,
            ownerId: ownerId,
            validFrom: validFrom,
            conversationKeyId: conversationKeyId,
            conversationKey: conversationKey,
            signature: signature)
    }
}
