/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct Device: Codable, Equatable {
    public let id: String
    public let ownerId: Int
    public let idOwnerIdSignature: String
    public let pubkey: String
    public var state: State
    public var blockTime: Date?

    public enum State: String, Codable {
        case pending
        case active
        case blocked
    }

    public init(id: String, ownerId: Int, idOwnerIdSignature: String, pubkey: String, state: State, blockTime: Date?) {
        self.id = id
        self.ownerId = ownerId
        self.idOwnerIdSignature = idOwnerIdSignature
        self.pubkey = pubkey
        self.state = state
        self.blockTime = blockTime
    }
}

public struct DeviceUpdate: Decodable {
    let state: Device.State
    let blockTime: Date?
}

public struct DeviceIdentifier: Codable {
    public let id: String
}
