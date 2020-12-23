/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public extension Operation {
    static func updateDevice(
        ctx: RequestContext, deviceID: String, update: DeviceUpdate
        ) -> OperationResult<Empty> {

        return ctx.transaction({ services in
            let device: Device
            switch services.devices.withID(deviceID) {
            case let .success(theDevice):
                guard let theDevice = theDevice else {
                    return .error(HandlerError(status: .notFound, publicDescription: "Device not found"))
                }
                device = theDevice
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }

            guard update.state == .active || ctx.authenticatedUserID! == device.ownerId else {
                return .error(HandlerError(
                    status: .unauthorized,
                    publicDescription: "The authenticated user must be the owner"))
            }

            let result: ServiceResult<Empty>
            switch update.state {
            case .pending:
                return .error(HandlerError(
                    status: .unprocessableEntity,
                    publicDescription: "Devices cannot be set to pending"))
            case .active:
                result = services.devices.activate(id: deviceID)
            case .blocked:
                guard let blockTime = update.blockTime else {
                    return .error(HandlerError(
                        status: .unprocessableEntity,
                        publicDescription: "When state is blocked, a blockTime is needed"))
                }
                result = services.devices.block(id: deviceID, blockTime: blockTime)
            }

            switch result {
            case .success:
                return .noContent
            case let .error(error):
                return .error(HandlerError(
                    status: .conflict, publicDescription: error.publicDescription))
            }
        })
    }
}
