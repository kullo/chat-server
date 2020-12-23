/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import HTTP
import Vapor

private struct RegisterDeviceRequestBody: Decodable {
    let device: Device
}

class DevicesRoutes: RouteCollection {
    private let _headerAuthMiddleware: HeaderAuthMiddleware
    private let _pvkAuthMiddleware: PasswordVerificationKeyAuthMiddleware
    private let _servicesFactory: ServicesFactory

    init(
        headerAuth: HeaderAuthMiddleware,
        pvkAuth: PasswordVerificationKeyAuthMiddleware,
        servicesFactory: ServicesFactory) {

        _headerAuthMiddleware = headerAuth
        _pvkAuthMiddleware = pvkAuth
        _servicesFactory = servicesFactory
    }

    func build(_ builder: RouteBuilder) throws {
        let devices = builder.grouped("v1", String.parameter, "devices")
        let headerAuthenticated = devices.grouped(_headerAuthMiddleware)

        devices.grouped(_pvkAuthMiddleware).operation(.post, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<Device> in
            let requestBody = try CodableRequest<RegisterDeviceRequestBody>(
                request: req, logger: ctx.log).body
            return Operation.addDevice(ctx: ctx, device: requestBody.device)
        }

        headerAuthenticated.operation(.get, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<ListResult<Device, DevicesRelated>> in
            let state = req.query?["state"]?.string
            return Operation.getDevices(ctx: ctx, state: state).map({
                ListResult(
                    objects: $0.devices,
                    related: DevicesRelated(users: $0.owners),
                    meta: ListMeta(nextCursor: nil))
            })
        }

        headerAuthenticated.operation(.patch, String.parameter, servicesFactory: _servicesFactory) {
            (req, ctx) -> OperationResult<Empty> in
            let deviceID = try req.parameters.next(String.self)
            let requestBody = try CodableRequest<DeviceUpdate>(request: req, logger: ctx.log).body
            return Operation.updateDevice(ctx: ctx, deviceID: deviceID, update: requestBody)
        }
    }
}

private struct DevicesRelated: Encodable {
        let users: [User]
}
