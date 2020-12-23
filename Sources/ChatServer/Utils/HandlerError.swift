/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public enum HTTPStatus: Int {
    case ok = 200
    case noContent = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case conflict = 409
    case unprocessableEntity = 422
    case internalServerError = 500
}

extension HTTPStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ok: return "OK"
        case .noContent: return "No Content"
        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .conflict: return "Conflict"
        case .unprocessableEntity: return "Unprocessable Entity"
        case .internalServerError: return "Internal Server Error"
        }
    }
}

public struct HandlerError: Error, PubliclyDescribable {
    public let status: HTTPStatus
    public let publicDescription: String
}
