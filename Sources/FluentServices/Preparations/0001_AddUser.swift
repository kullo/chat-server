/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0001_AddUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(UserEntity.self) { builder in
            builder.id()
            builder.string("state")
            builder.string("name")
            builder.string("email", unique: true)
            builder.string("picture", optional: true)
            builder.string("login_key")
            builder.string("password_verification_key")
            builder.string("encryption_pubkey")
            builder.string("encryption_privkey")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(UserEntity.self)
    }
}
