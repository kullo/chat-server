/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0003_AddConversation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(ConversationEntity.self) { builder in
            builder.id()
            builder.string("type")
            builder.string("title")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(ConversationEntity.self)
    }
}
