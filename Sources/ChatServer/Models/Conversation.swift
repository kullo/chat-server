/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public struct Conversation: Codable, Equatable {
    public typealias IDType = String

    public let id: IDType
    public let type: ConversationType
    public let title: String
    public var participantIds: [Int]

    public init(id: IDType, type: ConversationType, title: String, participantIds: [Int]) {
        self.id = id
        self.type = type
        self.title = title
        self.participantIds = participantIds
    }
}

extension Conversation: Comparable {
    public static func <(lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id < rhs.id
    }
}

public enum ConversationType: String, Codable {
    case channel = "channel"
    case group = "group"
}

public struct ConversationIdentifier: Codable {
    public let id: Conversation.IDType
}
