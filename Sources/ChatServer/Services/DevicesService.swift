/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public protocol ReadingDevicesService {
    func all() -> ServiceResult<[Device]>
    func withState(_ state: Device.State) -> ServiceResult<[Device]>
    func withID(_ id: String) -> ServiceResult<Device?>
}

public protocol DevicesService: ReadingDevicesService {
    func add(_ device: Device) -> ServiceResult<Device>
    func activate(id: String) -> ServiceResult<Empty>
    func block(id: String, blockTime: Date) -> ServiceResult<Empty>
}

public enum DevicesError: String, Error, PubliclyDescribable {
    public var publicDescription: String { return rawValue }

    case notFound = "Device not found"
    case inconsistentBlockTime = "Device blockTime must be nonnull iff state is blocked"
    case alreadyExists = "Device already exists"
    case notPending = "Non-pending device cannot be activated"
    case alreadyBlocked = "Device already blocked"
}
