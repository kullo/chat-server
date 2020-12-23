/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent

enum P0006_AddBlob: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(BlobEntity.self) { builder in
            builder.id()
            builder.string("content_type")
            builder.bytes("data")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(BlobEntity.self)
    }
}
