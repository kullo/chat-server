/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public enum Operation {}

public struct Empty: Codable {
    public init() {}
}

public struct Success<SuccessType: Encodable> {
    public let status: HTTPStatus
    public let data: SuccessType

    init(_ status: HTTPStatus, _ data: SuccessType) {
        self.status = status
        self.data = data
    }
}

public enum OperationResult<SuccessType: Encodable> {
    case success(Success<SuccessType>)
    case error(HandlerError)

    public static func ok(_ data: SuccessType) -> OperationResult<SuccessType> {
        return .success(Success(.ok, data))
    }

    public static func internalServerError(
        _ error: Error, logger: LogService,
        file: String = #file, function: String = #function, line: Int = #line
        ) -> OperationResult<SuccessType> {

        logger.error("Internal Server Error: \(error)", file: file, function: function, line: line)
        return .error(HandlerError(
            status: .internalServerError, publicDescription: "Internal Server Error"))
    }

    public func map<MappedType: Encodable>(_ transform: (SuccessType) -> MappedType)
        -> OperationResult<MappedType> {

        switch self {
        case let .success(result):
            return .success(Success(result.status, transform(result.data)))
        case let .error(error):
            return .error(error)
        }
    }
}

extension OperationResult where SuccessType == Empty {
    static let noContent = OperationResult.success(Success(.noContent, Empty()))
}
