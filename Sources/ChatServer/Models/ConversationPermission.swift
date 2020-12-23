/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct ConversationPermission: Codable, Equatable {
    public let conversationId: Conversation.IDType
    public let creatorId: Int
    public let ownerId: Int
    public let validFrom: DateString
    public let conversationKeyId: String
    public let conversationKey: String
    public let signature: String

    public init(
        conversationId: Conversation.IDType,
        creatorId: Int,
        ownerId: Int,
        validFrom: DateString,
        conversationKeyId: String,
        conversationKey: String,
        signature: String) {

        self.conversationId = conversationId
        self.creatorId = creatorId
        self.ownerId = ownerId
        self.validFrom = validFrom
        self.conversationKeyId = conversationKeyId
        self.conversationKey = conversationKey
        self.signature = signature
    }
}

extension ConversationPermission: Comparable {
    public static func <(lhs: ConversationPermission, rhs: ConversationPermission) -> Bool {
        guard lhs.validFrom == rhs.validFrom else { return lhs.validFrom < rhs.validFrom }
        return lhs.conversationId < rhs.conversationId
    }
}

public struct ConversationKeyIdentifier: Codable {
    public let conversationKeyId: String
}
