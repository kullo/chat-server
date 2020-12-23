/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct User: Encodable, Equatable {
    public let id: Int
    public var state: State
    public var name: String
    public var email: String
    public var picture: URL?
    public let loginKey: String
    public let passwordVerificationKey: String
    public let encryptionPubkey: String
    public let encryptionPrivkey: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case state = "state"
        case name = "name"
        case picture = "picture"
        case encryptionPubkey = "encryptionPubkey"
    }

    public enum State: String, Codable {
        case pending
        case active
    }

    public init(
        id: Int,
        state: State,
        name: String,
        email: String,
        picture: URL?,
        loginKey: String,
        passwordVerificationKey: String,
        encryptionPubkey: String,
        encryptionPrivkey: String) {

        self.id = id
        self.state = state
        self.name = name
        self.email = email
        self.picture = picture
        self.loginKey = loginKey
        self.passwordVerificationKey = passwordVerificationKey
        self.encryptionPubkey = encryptionPubkey
        self.encryptionPrivkey = encryptionPrivkey
    }

    static func fromNewUser(_ user: NewUser, id: Int, state: State) -> User {
        return User(
            id: id,
            state: state,
            name: user.name,
            email: user.email,
            picture: user.picture,
            loginKey: user.loginKey,
            passwordVerificationKey: user.passwordVerificationKey,
            encryptionPubkey: user.encryptionPubkey,
            encryptionPrivkey: user.encryptionPrivkey)
    }
}

public struct NewUser: Decodable {
    public let name: String
    public let email: String
    public let picture: URL?
    public let loginKey: String
    public let passwordVerificationKey: String
    public let encryptionPubkey: String
    public let encryptionPrivkey: String

    public init(
        name: String, email: String, picture: URL?, loginKey: String,
        passwordVerificationKey: String, encryptionPubkey: String, encryptionPrivkey: String) {

        self.name = name
        self.email = email
        self.picture = picture
        self.loginKey = loginKey
        self.passwordVerificationKey = passwordVerificationKey
        self.encryptionPubkey = encryptionPubkey
        self.encryptionPrivkey = encryptionPrivkey
    }
}

public struct UserUpdate: Decodable {
    public let state: User.State?
    public let name: String?
    public let email: String?
    public let picture: URL?
}

public struct UserIdentifier: Codable {
    public let id: Int
}
