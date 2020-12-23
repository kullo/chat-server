/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import RxSwift

public class FluentConversationPermissionsService {
    private let _executor: Executor
    private let _changeSubject: PublishSubject<ConversationPermissionsEvent>

    public init(_ executor: Executor, eventSubject: PublishSubject<ConversationPermissionsEvent>) {
        _executor = executor
        _changeSubject = eventSubject
    }
}

extension FluentConversationPermissionsService: ConversationPermissionsService {
    public var changeObservable: Observable<ConversationPermissionsEvent> {
        return _changeSubject.asObservable()
    }

    public func add(
        permissions newPermissions: [ConversationPermission],
        convID: Conversation.IDType,
        origin: ObjectIdentifier?) -> ServiceResult<Empty> {

        if newPermissions.isEmpty {
            return .success(Empty())
        }

        do {
            let keyIDs = newPermissions.map({ $0.conversationKeyId })
            let conflicts = try ConversationPermissionEntity.makeQuery()
                .filter("conversation_id" != convID)
                .filter("conversation_key_id", in: keyIDs)
                .count()
            guard conflicts == 0 else {
                return .error(ConversationPermissionsError.conflictingKeyID)
            }

            for permission in newPermissions {
                try ConversationPermissionEntity(permission: permission).save()
            }

            for permission in newPermissions {
                _changeSubject.onNext(ConversationPermissionsEvent(
                    origin: origin, type: .added(permission: permission)))
            }

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }

        return .success(Empty())
    }

    public func add(
        permissions: [ConversationPermission], origin: ObjectIdentifier?) -> ServiceResult<Empty> {

        let permissionsByConvID = Dictionary(grouping: permissions, by: { $0.conversationId })
        return permissionsByConvID.reduce(.success(Empty()), {
            previousResult, convIDPermissionsPair in
            switch previousResult {
            case .success:
                return add(permissions: convIDPermissionsPair.value, convID: convIDPermissionsPair.key, origin: origin)
            case .error:
                return previousResult
            }
        })
    }

    public func permission(forKey keyID: String, userID: Int) -> ServiceResult<ConversationPermission?> {
        return ConversationPermissionEntity.getOne(filter: { try $0
            .filter("conversation_key_id", keyID)
            .filter("owner_id", userID)
            .first()
        })
    }

    public func permissions(forOwner ownerID: Int) -> ServiceResult<[Conversation.IDType: [ConversationPermission]]> {
        do {
            let permissions = try ConversationPermissionEntity.makeQuery()
                .filter("owner_id", ownerID)
                .all()
                .map({ try $0.makeModel() })
            let result = Dictionary(grouping: permissions, by: { $0.conversationId })
            return .success(result)

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }

    public func permissions(forConversation convID: Conversation.IDType) -> ServiceResult<[ConversationPermission]> {
        return ConversationPermissionEntity.getMultiple(filter: { try $0
            .filter("conversation_id", convID)
            .all()
        })
    }

    public func isLatestForConversation(permission: ConversationPermission) -> ServiceResult<Bool> {
        let permissionsForConversation: [ConversationPermissionEntity]
        do {
            permissionsForConversation = try ConversationPermissionEntity.makeQuery()
                .filter("conversation_id", permission.conversationId)
                .all()
        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }

        if let latest = permissionsForConversation.max(by: { $0.validFrom < $1.validFrom }) {
            return .success(permission.validFrom >= latest.validFrom)
        } else {
            return .success(false)
        }
    }
}
