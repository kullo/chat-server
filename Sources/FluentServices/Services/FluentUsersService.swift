/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent

public class FluentUsersService {
    private let _executor: Executor

    public init(_ executor: Executor) {
        _executor = executor
    }
}

extension FluentUsersService: UsersService {
    public func all() -> ServiceResult<[User]> {
        return UserEntity.getMultiple(filter: { try $0.all() })
    }

    public func withState(_ state: User.State) -> ServiceResult<[User]> {
        return UserEntity.getMultiple(filter: { try $0.filter("state", state.rawValue).all() })
    }

    public func addUser(_ user: NewUser) -> ServiceResult<User> {
        let isFirstUser = (try? UserEntity.makeQuery().count() == 0) ?? true
        let state: User.State = isFirstUser ? .active : .pending

        let entity = UserEntity(newUser: user, state: state)

        do {
            try entity.save()
            return .success(entity.makeModel())
        } catch {
            if FluentErrorUtil.isConstraintViolation(error: error, column: "email") {
                return .error(UsersServiceError.conflictingEmail)
            } else {
                var serviceError = FluentServiceError.generalDatabaseError
                serviceError.reason = error
                return .error(serviceError)
            }
        }
    }

    public func withID(_ userID: Int) -> ServiceResult<User?> {
        return UserEntity.getOne(filter: { try $0.find(userID) })
    }

    public func withEmail(_ email: String) -> ServiceResult<User?> {
        return UserEntity.getOne(filter: { try $0.filter("email", email).first() })
    }

    public func update(id: Int, with update: UserUpdate) -> ServiceResult<Empty> {
        do {
            guard let entity = try UserEntity.makeQuery().find(id) else {
                return .error(UsersServiceError.notFound)
            }

            if let state = update.state {
                entity.state = state.rawValue
            }
            if let email = update.email {
                entity.email = email
            }
            if let name = update.name {
                entity.name = name
            }
            if let picture = update.picture {
                entity.picture = picture
            }

            try entity.save()
            return .success(Empty())

        } catch {
            if FluentErrorUtil.isConstraintViolation(error: error, column: "email") {
                return .error(UsersServiceError.conflictingEmail)
            } else {
                var serviceError = FluentServiceError.generalDatabaseError
                serviceError.reason = error
                return .error(serviceError)
            }
        }
    }
}
