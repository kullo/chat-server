/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation
import Sodium

public protocol AuthTokenService {
    func make(workspace: String, userID: Int) -> String
    func verifyAndExtractTokenData(token tokenStr: String, maxAge: TimeInterval) -> AuthTokenData?
}

public struct AuthTokenData: Codable {
    public let workspace: String
    public let userID: Int
    public let date: Date
}

public class AuthTokenManager {
    private let _encoder = JSONEncoder()
    private let _decoder = JSONDecoder()
    private let _sodium = Sodium()
    private let _encryptionKey: Data

    public init() {
        _encoder.dateEncodingStrategy = .secondsSince1970
        _decoder.dateDecodingStrategy = .secondsSince1970
        _encryptionKey = _sodium.secretBox.key()!
    }
}

extension AuthTokenManager: AuthTokenService {
    public func make(workspace: String, userID: Int) -> String {
        let data = AuthTokenData(workspace: workspace, userID: userID, date: Date())
        let token = try! _encoder.encode(data)
        let encryptedToken: Data = _sodium.secretBox.seal(message: token, secretKey: _encryptionKey)!
        return _sodium.utils.bin2base64(encryptedToken, variant: .URLSAFE)!
    }

    public func verifyAndExtractTokenData(token tokenStr: String, maxAge: TimeInterval) -> AuthTokenData? {
        guard
            let encryptedToken = _sodium.utils.base642bin(tokenStr, variant: .URLSAFE),
            let token = _sodium.secretBox.open(
                nonceAndAuthenticatedCipherText: encryptedToken, secretKey: _encryptionKey),
            let data = try? _decoder.decode(AuthTokenData.self, from: token),
            -data.date.timeIntervalSinceNow <= maxAge
            else { return nil }
        return data
    }
}
