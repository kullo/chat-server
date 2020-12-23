/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import PostgreSQL
import SQLite

struct FluentServiceError: PubliclyDescribableError {
    let publicDescription: String
    var reason: Error?

    static let generalDatabaseError =
        FluentServiceError(publicDescription: "General database error", reason: nil)
}

extension FluentServiceError: CustomStringConvertible {
    var description: String {
        return "FluentServiceError: \(publicDescription); reason: \(String(describing: reason))"
    }
}

struct FluentErrorUtil {
    static func isConstraintViolation(error: Error, column: String) -> Bool {
        if let sqliteError = error as? StatusError,
            case let .constraint(msg) = sqliteError,
            msg.contains(column) {
            return true
        } else if let postgresError = error as? PostgreSQLError,
            postgresError.code == .uniqueViolation,
            postgresError.reason.contains(column) {
            return true
        } else {
            return false
        }
    }
}
