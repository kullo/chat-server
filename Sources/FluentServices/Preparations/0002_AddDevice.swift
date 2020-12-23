/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0002_AddDevice: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(DeviceEntity.self) { builder in
            builder.id()
            builder.foreignId(for: UserEntity.self, foreignIdKey: "owner_id")
            builder.string("id_owner_id_signature")
            builder.string("pubkey")
            builder.string("state")
            builder.date("block_time", optional: true)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(DeviceEntity.self)
    }
}
