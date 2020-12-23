/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func addDevice(
        ctx: RequestContext, device: Device
        ) -> OperationResult<Device> {

        guard device.state == .pending else {
            return .error(HandlerError(
                status: .unprocessableEntity,
                publicDescription: "New devices must be pending"))
        }

        guard ctx.authenticatedUserID! == device.ownerId else {
            return .error(HandlerError(
                status: .unauthorized,
                publicDescription: "The authenticated user must be the owner"))
        }

        return ctx.transaction({ services in
            switch services.devices.add(device) {
            case let .success(registeredDevice):
                return .ok(registeredDevice)
            case let .error(error):
                let status: HTTPStatus = (error as? DevicesError == .alreadyExists) ? .conflict : .unprocessableEntity
                return .error(HandlerError(
                    status: status, publicDescription: error.publicDescription))
            }
        })
    }
}
