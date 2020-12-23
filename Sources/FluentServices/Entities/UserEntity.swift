/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

final class UserEntity: Entity {
    static let idType = IdentifierType.int

    let storage = Storage()

    var state: String
    var name: String
    var email: String
    var picture: URL?
    let loginKey: String
    let passwordVerificationKey: String
    let encryptionPubkey: String
    let encryptionPrivkey: String

    init(newUser user: NewUser, state newState: User.State) {
        state = newState.rawValue
        name = user.name
        email = user.email
        picture = user.picture
        loginKey = user.loginKey
        passwordVerificationKey = user.passwordVerificationKey
        encryptionPubkey = user.encryptionPubkey
        encryptionPrivkey = user.encryptionPrivkey
    }

    init(row: Row) throws {
        state = try row.get("state")
        name = try row.get("name")
        email = try row.get("email")
        let rawPicture: String? = try row.get("picture")
        picture = rawPicture != nil ? URL(string: rawPicture!) : nil
        loginKey = try row.get("login_key")
        passwordVerificationKey = try row.get("password_verification_key")
        encryptionPubkey = try row.get("encryption_pubkey")
        encryptionPrivkey = try row.get("encryption_privkey")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("state", state)
        try row.set("name", name)
        try row.set("email", email)
        try row.set("picture", picture?.absoluteString)
        try row.set("login_key", loginKey)
        try row.set("password_verification_key", passwordVerificationKey)
        try row.set("encryption_pubkey", encryptionPubkey)
        try row.set("encryption_privkey", encryptionPrivkey)
        return row
    }
}

extension UserEntity: ModelConvertible {
    typealias ModelType = User

    func makeModel() -> User {
        return User(
            id: id!.wrapped.int!,
            state: User.State(rawValue: state)!,
            name: name,
            email: email,
            picture: picture,
            loginKey: loginKey,
            passwordVerificationKey: passwordVerificationKey,
            encryptionPubkey: encryptionPubkey,
            encryptionPrivkey: encryptionPrivkey)
    }
}
