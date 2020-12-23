/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation
import RxSwift

public struct ConversationPermissionsEvent {
    public enum EventType {
        case added(permission: ConversationPermission)
    }

    public let origin: ObjectIdentifier?
    public let type: EventType

    public init(origin: ObjectIdentifier?, type: EventType) {
        self.origin = origin
        self.type = type
    }
}

public protocol ConversationPermissionsService {
    var changeObservable: Observable<ConversationPermissionsEvent> { get }

    func add(
        permissions: [ConversationPermission],
        convID: Conversation.IDType,
        origin: ObjectIdentifier?) -> ServiceResult<Empty>
    func add(
        permissions: [ConversationPermission],
        origin: ObjectIdentifier?) -> ServiceResult<Empty>
    func permission(forKey keyID: String, userID: Int) -> ServiceResult<ConversationPermission?>
    func permissions(forOwner ownerID: Int) -> ServiceResult<[Conversation.IDType: [ConversationPermission]]>
    func permissions(forConversation convID: Conversation.IDType) -> ServiceResult<[ConversationPermission]>
    func isLatestForConversation(permission: ConversationPermission) -> ServiceResult<Bool>
}

public enum ConversationPermissionsError: String, Error, PubliclyDescribable {
    public var publicDescription: String { return rawValue }

    case conflictingKeyID = "Conversation Key ID exists in another conversation"
}
