/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation

public enum FluentServicesTesting{
    public static func addUsers(_ users: [(NewUser, User.State)]) {
        for user in users {
            try! UserEntity(newUser: user.0, state: user.1).save()
        }
    }

    public static func addDevices(_ devices: [Device]) {
        for device in devices {
            try! DeviceEntity(device: device).save()
        }
    }

    public static func addConversations(_ conversations: [Conversation]) {
        for conversation in conversations {
            let entity = ConversationEntity(conversation: conversation)
            try! entity.save()
            for participantID in conversation.participantIds {
                let user = try! UserEntity.makeQuery().find(participantID)
                try! entity.participants.add(user!)
            }
        }
    }

    public static func addPermissions(_ permissions: [Conversation.IDType: [ConversationPermission]]) {
        for (_, permissionList) in permissions {
            for permission in permissionList {
                try! ConversationPermissionEntity(permission: permission).save()
            }
        }
    }

    public static func addMessages(_ messages: [Conversation.IDType: [NewMessage]]) {
        for (conversationID, messageList) in messages {
            for message in messageList {
                let entity = MessageEntity(
                    newMessage: message, conversationId: conversationID,
                    timeSent: Date(), edited: false)
                try! entity.save()
            }
        }
    }
}
