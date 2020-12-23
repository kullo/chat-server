/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct AuthorizationHeader {
    public let loginKey: String
    public let signature: String
    public let deviceID: String
}

// key="value"
private let keyValuePair = "([A-Za-z]+)=\"([^\"]*)\""
private let doubleKeyValueRegex = try! NSRegularExpression(
    // key="value", key="value"
    pattern: "\\A\\s*" + keyValuePair + "\\s*,\\s*" + keyValuePair + "\\s*\\z",
    options: [])

public struct AuthorizationHeaderParser {
    private let _log: LogService

    public init(logger: LogService) {
        _log = logger
    }

    public func parseAuthHeader(_ header: String) -> AuthorizationHeader? {
        let typeAndCredentials = header.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard typeAndCredentials.count == 2 else {
            _log.error("Bad Authorization header: typeAndCredentials.count == \(typeAndCredentials.count)")
            return nil
        }
        let type = typeAndCredentials[0]
        let credentials = typeAndCredentials[1]

        guard type == "KULLO_V1" else {
            _log.error("Bad Authorization header: type == \(type)")
            return nil
        }

        let dict = parseKeyValuePairs(String(credentials))
        guard let loginKey = dict["loginKey"] else {
            _log.error("Bad Authorization header: loginKey missing")
            return nil
        }
        guard let deviceIDAndSignature = dict["signature"]?.split(separator: ",") else {
            _log.error("Bad Authorization header: signature missing")
            return nil
        }
        guard deviceIDAndSignature.count == 2 else {
            _log.error("Bad Authorization header: deviceIDAndSignature.count == \(deviceIDAndSignature.count)")
            return nil
        }

        let deviceID = String(deviceIDAndSignature[0])
        let signature = String(deviceIDAndSignature[1])
        return AuthorizationHeader(loginKey: loginKey, signature: signature, deviceID: deviceID)
    }

    private func parseKeyValuePairs(_ raw: String) -> [String: String] {
        let fullRange = NSRange(raw.startIndex..<raw.endIndex, in: raw)

        let fullMatches = doubleKeyValueRegex.matches(in: raw, options: [], range: fullRange)
        guard let fullMatch = fullMatches.first else {
            return [:]
        }

        var result = [String: String]()
        for group in stride(from: 1, to: fullMatch.numberOfRanges - 1, by: 2) {
            if
                let key = raw.substring(with: fullMatch.range(at: group)),
                let value = raw.substring(with: fullMatch.range(at: group + 1)) {
                result[String(key)] = String(value)
            }
        }
        return result
    }
}

private extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else {
            return nil
        }
        return self[range]
    }
}
