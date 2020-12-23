/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent

public class FluentDevicesService {
    private let _executor: Executor

    public init(_ executor: Executor) {
        _executor = executor
    }
}

extension FluentDevicesService: DevicesService {
    public func all() -> ServiceResult<[Device]> {
        return DeviceEntity.getMultiple(filter: { try $0.all() })
    }

    public func withState(_ state: Device.State) -> ServiceResult<[Device]> {
        return DeviceEntity.getMultiple(filter: { try $0.filter("state", state.rawValue).all() })
    }

    public func withID(_ id: String) -> ServiceResult<Device?> {
        return DeviceEntity.getOne(filter: { try $0.find(id) })
    }

    public func add(_ device: Device) -> ServiceResult<Device> {
        guard (device.state == .blocked) == (device.blockTime != nil) else {
            return .error(DevicesError.inconsistentBlockTime)
        }

        let isFirstDevice = (try? DeviceEntity.makeQuery().count() == 0) ?? true
        let state: Device.State = isFirstDevice ? .active : .pending

        var mutableDevice = device
        mutableDevice.state = state

        let entity = DeviceEntity(device: mutableDevice)

        do {
            try entity.save()
            return .success(mutableDevice)
        } catch {
            if FluentErrorUtil.isConstraintViolation(error: error, column: "id") {
                return .error(DevicesError.alreadyExists)
            } else {
                var serviceError = FluentServiceError.generalDatabaseError
                serviceError.reason = error
                return .error(serviceError)
            }
        }
    }

    public func activate(id: String) -> ServiceResult<Empty> {
        do {
            guard let entity = try DeviceEntity.makeQuery().find(id) else {
                return .error(DevicesError.notFound)
            }

            guard entity.state == .pending else {
                return .error(DevicesError.notPending)
            }

            entity.state = .active
            try entity.save()
            return .success(Empty())

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }

    //TODO: dedupe with activate
    public func block(id: String, blockTime: Date) -> ServiceResult<Empty> {
        do {
            guard let entity = try DeviceEntity.makeQuery().find(id) else {
                return .error(DevicesError.notFound)
            }

            guard entity.state != .blocked else {
                return .error(DevicesError.alreadyBlocked)
            }

            entity.state = .blocked
            entity.blockTime = blockTime
            try entity.save()
            return .success(Empty())

        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }
}
