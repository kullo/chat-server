/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import Vapor

class HeaderAuthMiddleware {
    private let _users: ReadingUsersService
    private let _devices: ReadingDevicesService
    private let _log: LogService
    private let _parser: AuthorizationHeaderParser
    private static let parsingError = Abort(.badRequest, reason: "Bad Authorization header")

    init(users: ReadingUsersService, devices: ReadingDevicesService, logger: LogService) {
        _users = users
        _devices = devices
        _log = logger
        _parser = AuthorizationHeaderParser(logger: _log)
    }
}

extension HeaderAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let rawHeader = request.headers[.authorization] else {
            _log.error("No Authorization header")
            throw Abort(.unauthorized)
        }
        guard let authHeader = _parser.parseAuthHeader(rawHeader) else {
            throw Abort(.unauthorized)
        }

        let device: Device
        switch _devices.withID(authHeader.deviceID) {
        case let .success(theDevice):
            guard let theDevice = theDevice else {
                _log.error("Device not found: \(authHeader.deviceID)")
                throw Abort(.unauthorized)
            }
            device = theDevice
        case let .error(error):
            _log.error("Failed to get device: \(error)")
            throw Abort(.internalServerError)
        }
        guard device.state == .active else {
            _log.error("Device not active: \(authHeader.deviceID)")
            throw Abort(.unauthorized)
        }

        let user: User
        switch _users.withID(device.ownerId) {
        case let .success(theUser):
            guard let theUser = theUser else {
                _log.error("User not found: \(device.ownerId)")
                throw Abort(.unauthorized)
            }
            guard theUser.state == .active else {
                _log.error("User not active: \(device.ownerId)")
                throw Abort(.unauthorized)
            }
            user = theUser
        case let .error(error):
            _log.error("While authenticating with login key: \(error)")
            throw Abort(.internalServerError)
        }

        let crypto = CryptoUtil()

        guard let detachedSignature = Data(base64Encoded: authHeader.signature),
            let loginKey = Data(base64Encoded: authHeader.loginKey),
            let devicePubkey = Data(base64Encoded: device.pubkey)
            else { throw HeaderAuthMiddleware.parsingError }

        // don't short-circuit to prevent timing side-channel
        let loginKeyValid = user.loginKey == authHeader.loginKey
        let signatureValid = crypto.verify(
            detachedSignature: detachedSignature, for: loginKey, pubkey: devicePubkey)

        guard loginKeyValid else {
            _log.error("Invalid loginKey for user: \(device.ownerId)")
            throw Abort(.unauthorized)
        }
        guard signatureValid else {
            _log.error("Invalid signature for device: \(device.id)")
            throw Abort(.unauthorized)
        }

        request.userID = user.id
        request.user = user
        return try next.respond(to: request)
    }
}

extension Request {
    private static let _userIDKey = "kullo.userID"
    private static let _userKey = "kullo.user"

    var userID: Int? {
        get { return storage[Request._userIDKey] as! Int? }
        set { storage[Request._userIDKey] = newValue }
    }

    var user: User? {
        get { return storage[Request._userKey] as! User? }
        set { storage[Request._userKey] = newValue }
    }
}
