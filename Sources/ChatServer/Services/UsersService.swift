/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public protocol ReadingUsersService {
    func all() -> ServiceResult<[User]>
    func withState(_ state: User.State) -> ServiceResult<[User]>
    func withID(_ userID: Int) -> ServiceResult<User?>
    func withEmail(_ email: String) -> ServiceResult<User?>
}

public protocol UsersService: ReadingUsersService {
    func addUser(_ user: NewUser) -> ServiceResult<User>
    func update(id: Int, with: UserUpdate) -> ServiceResult<Empty>
}

public enum UsersServiceError: String, PubliclyDescribableError {
    public var publicDescription: String { return rawValue }

    case conflictingEmail = "User with email address does already exist"
    case notFound = "User not found"
}
