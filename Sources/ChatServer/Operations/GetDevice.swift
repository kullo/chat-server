/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public extension Operation {
    static func getDevice(ctx: RequestContext, deviceID: String)
        -> OperationResult<Device> {

        return ctx.transaction({ services in
            switch services.devices.withID(deviceID) {
            case let .success(device):
                guard let device = device else {
                    return .error(HandlerError(status: .notFound, publicDescription: "Device not found"))
                }
                return .ok(device)
            case let .error(error):
                return .internalServerError(error, logger: ctx.log)
            }
        })
    }
}
