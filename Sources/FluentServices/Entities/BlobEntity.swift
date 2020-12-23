/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

public final class BlobEntity: Entity {
    public static let idType = IdentifierType.custom("TEXT")

    public let storage = Storage()

    public let contentType: String
    public let data: Data

    public init(id: String, contentType: String, data: Data) {
        self.contentType = contentType
        self.data = data

        self.id = Identifier(id, in: nil)
    }

    public init(row: Row) throws {
        contentType = try row.get("content_type")
        data = Data(bytes: try Blob(node: row.get("data")).bytes)
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("content_type", contentType)
        try row.set("data", Blob(bytes: data.makeBytes()))
        return row
    }
}
