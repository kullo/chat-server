/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0004_AddConversationPermission: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ConversationPermissionEntity.self) { builder in
            builder.id()
            builder.foreignId(for: ConversationEntity.self, foreignIdKey: "conversation_id")
            builder.foreignId(for: UserEntity.self, foreignIdKey: "creator_id")
            builder.foreignId(for: UserEntity.self, foreignIdKey: "owner_id")
            builder.string("valid_from")
            builder.string("conversation_key_id")
            builder.string("conversation_key")
            builder.string("signature")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(ConversationPermissionEntity.self)
    }
}
