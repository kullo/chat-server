/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent
import Foundation

final class DeviceEntity: Entity {
    static let idType = IdentifierType.custom("TEXT")

    let storage = Storage()

    let ownerId: Int
    let idOwnerIdSignature: String
    let pubkey: String
    var state: Device.State
    var blockTime: Date?

    init(device: Device) {
        ownerId = device.ownerId
        idOwnerIdSignature = device.idOwnerIdSignature
        pubkey = device.pubkey
        state = device.state
        blockTime = device.blockTime

        id = Identifier(device.id, in: nil)
    }

    init(row: Row) throws {
        ownerId = try row.get("owner_id")
        idOwnerIdSignature = try row.get("id_owner_id_signature")
        pubkey = try row.get("pubkey")
        state = Device.State(rawValue: try row.get("state"))!
        blockTime = try row.get("block_time")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("owner_id", ownerId)
        try row.set("id_owner_id_signature", idOwnerIdSignature)
        try row.set("pubkey", pubkey)
        try row.set("state", state.rawValue)
        try row.set("block_time", blockTime)
        return row
    }
}

extension DeviceEntity: ModelConvertible {
    typealias ModelType = Device

    func makeModel() throws -> Device {
        return Device(
            id: id!.wrapped.string!,
            ownerId: ownerId,
            idOwnerIdSignature: idOwnerIdSignature,
            pubkey: pubkey,
            state: state,
            blockTime: blockTime)
    }
}
