/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getDevices(ctx: RequestContext, state rawState: String?) -> OperationResult<DevicesAndOwners> {
        return ctx.transaction({ services in
            let devicesResult: ServiceResult<[Device]>
            if let rawState = rawState {
                guard let state = Device.State(rawValue: rawState) else {
                    return .error(HandlerError(
                        status: .unprocessableEntity,
                        publicDescription: "Unknown state: \(rawState)"))
                }
                devicesResult = services.devices.withState(state)
            } else {
                devicesResult = services.devices.all()
            }

            let devices: [Device]
            switch devicesResult {
            case let .success(theDevices):
                devices = theDevices
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            var owners = [User]()
            for ownerID in Set(devices.map({ $0.ownerId })).sorted() {
                switch services.users.withID(ownerID) {
                case let .success(owner):
                    guard let owner = owner else {
                        return .internalServerError(UsersServiceError.notFound, logger: ctx.log)
                    }
                    owners.append(owner)
                case let .error(error):
                    return .internalServerError(error, logger: ctx.log)
                }
            }
            return .ok(DevicesAndOwners(devices: devices, owners: owners))
        })
    }
}

public struct DevicesAndOwners: Encodable {
    public let devices: [Device]
    public let owners: [User]
}
