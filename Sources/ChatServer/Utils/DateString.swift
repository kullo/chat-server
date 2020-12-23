/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct DateString {
    public let date: Date
    public let string: String

    public init(_ date: Date) {
        self.date = date
        self.string = DateString.formatter.string(from: date)
    }

    public init?(rfc3339String: String) {
        guard let date = DateString.formatter.date(from: rfc3339String) else {
            return nil
        }
        self.date = date
        self.string = rfc3339String
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension DateString: Equatable {
    public static func == (lhs: DateString, rhs: DateString) -> Bool {
        return lhs.string == rhs.string
    }
}

extension DateString: Comparable {
    public static func < (lhs: DateString, rhs: DateString) -> Bool {
        return lhs.date < rhs.date
    }
}

extension DateString: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        date = try container.decode(Date.self)
        string = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
