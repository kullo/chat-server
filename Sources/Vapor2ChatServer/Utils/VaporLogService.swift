/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Vapor

public struct VaporLogService {
    private let _logger: LogProtocol

    public init(logger: LogProtocol) {
        _logger = logger
    }
}

extension VaporLogService: LogService {
    public func log(_ level: ChatServer.LogLevel, message: String, file: String, function: String, line: Int) {
        _logger.log(convertLogLevel(level), message: message, file: file, function: function, line: line)
    }

    private func convertLogLevel(_ level: ChatServer.LogLevel) -> Vapor.LogLevel {
        switch level {
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        case .fatal: return .fatal
        }
    }
}
