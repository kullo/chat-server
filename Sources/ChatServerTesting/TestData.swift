/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation

enum TestData {

    static let devices = [
        // privkey: uar5NvF+wUEN+T0Do6AIB4Wdro4k5DGs958mZiadrvE=
        Device(
            id: "123abc",
            ownerId: 1,
            idOwnerIdSignature: "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
            pubkey: "WTf5bFDh+3shgdJpHkTb4mxLE6IHHB/rj1KbehMaT9Q=",
            state: .active,
            blockTime: nil
        ),
        // privkey: sJyKuOtX3XjtVvNMOW+1aqiJBiEkhWfBSKVJamRDcOA=
        Device(
            id: "456def",
            ownerId: 2,
            idOwnerIdSignature: "asdf",
            pubkey: "zVclGMiApcoBmoo4guY3a/vb4bpt8JPu7RLGx1oS9Q0=",
            state: .active,
            blockTime: nil
        ),
        Device(
            id: "789ghi",
            ownerId: 1,
            idOwnerIdSignature: "fdsa",
            pubkey: "rewq",
            state: .pending,
            blockTime: nil
        ),
        Device(
            id: "abcjkl",
            ownerId: 2,
            idOwnerIdSignature: "asdfasdf",
            pubkey: "qwerqwer",
            state: .pending,
            blockTime: nil
        ),
    ]

    static let users = [
        makeDummyUser(
            id: 1,
            state: .active,
            name: "The Answer",
            email: "answer@example.com",
            picture: URL(string: "https://www.example.com/theanswer.jpg")!,
            password: "password"),
        makeDummyUser(
            id: 2,
            state: .active,
            name: "Another User",
            email: "another@example.com",
            picture: nil,
            password: "password2"),
    ]

    static let usersWithPendingUser = [
        makeDummyUser(
            id: 1,
            state: .active,
            name: "The Answer",
            email: "answer@example.com",
            picture: URL(string: "https://www.example.com/theanswer.jpg")!,
            password: "password"),
        makeDummyUser(
            id: 2,
            state: .pending,
            name: "Another User",
            email: "another@example.com",
            picture: nil,
            password: "password2"),
    ]

    static let conversations = [
        Conversation(
            id: "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
            type: .channel, title: "Some Channel", participantIds: [1]),
        Conversation(
            id: "d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35",
            type: .group, title: "Some Group", participantIds: [1, 2]),
    ]

    static let messages: [Conversation.IDType: [NewMessage]] = [
        "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b": [
            NewMessage(
                context: MessageContext(
                    version: 1, parentMessageId: 0, previousMessageId: 0,
                    conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac", deviceKeyId: "123abc"),
                encryptedMessage: "dummy"),
        ],
    ]

    static func makeDummyUser(
        id: Int, state: User.State, name: String, email: String, picture: URL?, password: String
        ) -> (NewUser, User.State) {

        let keys = CryptoUtil().makeUserKeys(id: id, password: password)
        return (NewUser(
            name: name, email: email, picture: picture,
            loginKey: keys.loginKey, passwordVerificationKey: keys.passwordVerificationKey,
            encryptionPubkey: keys.encryptionPubkey, encryptionPrivkey: keys.encryptionPrivkey), state)
    }

    private static let calendar = Calendar(identifier: .gregorian)
    private static let utc = TimeZone(abbreviation: "UTC")!
    private static let earlierDate = {
        return calendar.date(
            from: DateComponents(
                timeZone: utc, year: 2018, month: 1, day: 1))!
    }()
    private static let laterDate = {
        return calendar.date(
            from: DateComponents(
                timeZone: utc, year: 2018, month: 1, day: 2))!
    }()

    private static func makeDummyPermissions(forOwner ownerID: Int) -> [Conversation.IDType: [ConversationPermission]] {
        let convID = conversations.first!.id
        return [
            convID: [
                ConversationPermission(
                    conversationId: convID,
                    creatorId: 1,
                    ownerId: ownerID,
                    validFrom: DateString(earlierDate),
                    conversationKeyId: "961e57c49ac08a897349d862ccc3f2f2",
                    conversationKey: "99a47eCaRcfC0/0WiiiexgP0C8QwgGDSYWSA2vO380g=",
                    signature: "TODO"),
                ConversationPermission(
                    conversationId: convID,
                    creatorId: 1,
                    ownerId: ownerID,
                    validFrom: DateString(laterDate),
                    conversationKeyId: "ef0a99b55a599f09e4f8663ee15864ac",
                    conversationKey: "J2bmzezHTW7U5CeyqPWxMfkM/ZsKeLUC4bP14310TSc=",
                    signature: "TODO"),
            ],
        ]
    }

    public static let permissions = makeDummyPermissions(forOwner: 1)
        .merging(makeDummyPermissions(forOwner: 2), uniquingKeysWith: { $0 + $1 })
}
