/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Fluent
import Foundation
import PostgreSQLDriver

private let allPreparations: [Preparation.Type] = [
    P0001_AddUser.self,
    P0002_AddDevice.self,
    P0003_AddConversation.self,
    Pivot<ConversationEntity, UserEntity>.self,
    P0004_AddConversationPermission.self,
    P0005_AddMessage.self,
    P0006_AddBlob.self,
]

private let db: Database = {
    let driver: Fluent.Driver

    if let dbURL = ProcessInfo.processInfo.environment["DATABASE_URL"] {
        let pgURL = PGURL(dbURL)!
        driver = try! PostgreSQLDriver.Driver(
            masterHostname: pgURL.host, readReplicaHostnames: [],
            user: pgURL.user, password: pgURL.password,
            database: pgURL.db, port: pgURL.port)
    } else {
        driver = try! MemoryDriver()
    }

    return Database(driver)
}()

private struct PGURL {
    let host: String
    let user: String
    let password: String
    let db: String
    let port: Int

    init?(_ string: String) {
        guard
            let url = URL(string: string),
            let host = url.host,
            let user = url.user,
            let password = url.password,
            url.pathComponents.count >= 2,
            let port = url.port
        else {
            return nil
        }
        let db = url.pathComponents[1]

        self.host = host
        self.user = user
        self.password = password
        self.db = db
        self.port = port
    }
}

public func setup(deleteAllData: Bool) throws {
    Database.default = db

    if deleteAllData {
        for preparation in allPreparations.reversed() {
            _ = try? db.revertAll([preparation])
        }
        try db.revertMetadata()
    }
    try db.prepare(allPreparations)
}
