/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Clibsodium
import Foundation
import Sodium

public class CryptoUtil {
    private let _sodium = Sodium()

    public init() {}

    public func verify(detachedSignature: Data, for message: Data, pubkey: Data) -> Bool {
        return _sodium.sign.verify(message: message, publicKey: pubkey, signature: detachedSignature)
    }

    public struct UserKeys {
        public let loginKey: String
        public let passwordVerificationKey: String
        public let encryptionPubkey: String
        public let encryptionPrivkey: String
        public let encryptionPrivkeyUnencrypted: String
    }

    public func makeUserKeys(id: Int, password: String) -> UserKeys {
        let masterKey: Data
        switch password { // speed up tests with canned answers
        case "password":
            masterKey = Data(base64Encoded: "27atcsOrVKUFdN9oJgF5VyGeRezuAM5+5MyWNRUu1AM=")!
        case "password2":
            masterKey = Data(base64Encoded: "AEvFQNksH3PK5kQU7S/TY3NmxWOhQcWPPGLM4GSkA1c=")!
        default:
            masterKey = _sodium.pwHash.hash(
                outputLength: 32,
                passwd: Data(password.utf8),
                salt: Data(count: 16),
                opsLimit: 20,
                memLimit: 64 * 1024 * 1024,
                alg: .Argon2ID13)!
        }

        let personalization = Data("CHATv001\0\0\0\0\0\0\0\0".utf8)
        var loginKeySalt = Data(count: 16)
        loginKeySalt[0] = 1
        var passwordVerificationKeySalt = Data(count: 16)
        passwordVerificationKeySalt[0] = 2
        var privkeyEncryptingKeySalt = Data(count: 16)
        privkeyEncryptingKeySalt[0] = 3

        let loginKey = _sodium.genericHash.blake2b(
            message: Data(),
            key: masterKey,
            outputLength: 32,
            salt: loginKeySalt,
            personal: personalization)!

        let passwordVerificationKey = _sodium.genericHash.blake2b(
            message: Data(),
            key: masterKey,
            outputLength: 32,
            salt: passwordVerificationKeySalt,
            personal: personalization)!

        let privkeyEncryptingKey = _sodium.genericHash.blake2b(
            message: Data(),
            key: masterKey,
            outputLength: 32,
            salt: privkeyEncryptingKeySalt,
            personal: personalization)!

        var keyPairSeed = Data(count: _sodium.box.SeedBytes)
        keyPairSeed[0] = UInt8(id)
        let keyPair = _sodium.box.keyPair(seed: keyPairSeed)!
        let privkeyEncrypted = encryptSymmetrically(
            message: keyPair.secretKey, key: privkeyEncryptingKey)!

        return UserKeys(
            loginKey: _sodium.utils.bin2base64(loginKey, variant: .ORIGINAL)!,
            passwordVerificationKey: _sodium.utils.bin2base64(passwordVerificationKey, variant: .ORIGINAL)!,
            encryptionPubkey: _sodium.utils.bin2base64(keyPair.publicKey, variant: .ORIGINAL)!,
            encryptionPrivkey: _sodium.utils.bin2base64(privkeyEncrypted, variant: .ORIGINAL)!,
            encryptionPrivkeyUnencrypted: _sodium.utils.bin2base64(keyPair.secretKey, variant: .ORIGINAL)!
        )
    }

    func encryptAsymmetrically(message: Data, pubkey: Data, privkey: Data) -> Data? {
        return _sodium.box.seal(message: message, recipientPublicKey: pubkey, senderSecretKey: privkey)
    }

    func encryptSymmetrically(message: Data, key: Data, testingNonce: Data? = nil) -> Data? {
        guard key.count == crypto_aead_chacha20poly1305_IETF_KEYBYTES,
            let nonceLength = Int(exactly: crypto_aead_chacha20poly1305_ietf_NPUBBYTES),
            let authTagLength = Int(exactly: crypto_aead_chacha20poly1305_IETF_ABYTES) else {
            return nil
        }

        let nonce: Data
        if let testingNonce = testingNonce {
            guard testingNonce.count == nonceLength else { return nil }
            nonce = testingNonce
        } else {
            var randomNonce = Data(count: nonceLength)
            randomNonce.withUnsafeMutableBytes { noncePtr in
                randombytes_buf(noncePtr, nonceLength)
            }
            nonce = randomNonce
        }

        var ciphertext = Data(count: message.count + authTagLength)
        var ciphertextLength: CUnsignedLongLong = 0

        let result = ciphertext.withUnsafeMutableBytes { ciphertextPtr in
            message.withUnsafeBytes { messagePtr in
                nonce.withUnsafeBytes { noncePtr in
                    key.withUnsafeBytes { keyPtr in
                        crypto_aead_chacha20poly1305_ietf_encrypt(
                            ciphertextPtr, &ciphertextLength,
                            messagePtr, CUnsignedLongLong(message.count),
                            nil, 0, // authenticated data
                            nil, // private nonce
                            noncePtr,
                            keyPtr)
                    }
                }
            }
        }
        guard result == 0, let length = Int(exactly: ciphertextLength) else { return nil }
        ciphertext.removeSubrange(length..<ciphertext.endIndex)
        ciphertext.insert(contentsOf: nonce, at: ciphertext.startIndex)
        return ciphertext
    }
}
