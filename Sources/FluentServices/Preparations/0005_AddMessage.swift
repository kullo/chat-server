/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0005_AddMessage: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(MessageEntity.self) { builder in
            builder.id()
            builder.foreignId(for: ConversationEntity.self, foreignIdKey: "conversation_id")
            builder.date("time_sent")
            builder.bool("edited")
            builder.int("ctx_version")
            builder.foreignId(for: MessageEntity.self, optional: true, foreignIdKey: "ctx_parent_message_id")
            builder.foreignId(for: MessageEntity.self, optional: true, foreignIdKey: "ctx_previous_message_id")
            builder.string("ctx_conversation_key_id")
            builder.foreignId(for: DeviceEntity.self, optional: true, foreignIdKey: "ctx_device_key_id")
            builder.string("encrypted_message")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(MessageEntity.self)
    }
}
