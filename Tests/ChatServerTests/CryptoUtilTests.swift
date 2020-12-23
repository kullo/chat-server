/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import XCTest

@testable import ChatServer

class CryptoUtilTests: XCTestCase {
    private var _uut: CryptoUtil!

    override func setUp() {
        super.setUp()
        _uut = CryptoUtil()
    }

    func testEncryptSymmetricallyWithWrongKeyLength() {
        let ciphertext = _uut.encryptSymmetrically(
            message: Data(),
            key: Data(count: 31),
            testingNonce: Data(count: 12))

        XCTAssertNil(ciphertext)
    }

    func testEncryptSymmetricallyWithWrongNonceLength() {
        let ciphertext = _uut.encryptSymmetrically(
            message: Data(),
            key: Data(count: 32),
            testingNonce: Data(count: 11))

        XCTAssertNil(ciphertext)
    }

    func testEncryptEmptyStringSymmetrically() {
        let ciphertext = _uut.encryptSymmetrically(
            message: Data(),
            key: Data(count: 32),
            testingNonce: Data(count: 12))

        XCTAssertNotNil(ciphertext)
        XCTAssertEqual(ciphertext!.base64EncodedString(), "AAAAAAAAAAAAAAAATrlyyaj7Ohs4K7TTb1/60Q==")
    }

    func testEncryptNonEmptyStringSymmetrically() {
        let ciphertext = _uut.encryptSymmetrically(
            message: Data(base64Encoded: "YWI=")!,
            key: Data(count: 32),
            testingNonce: Data(count: 12))

        XCTAssertNotNil(ciphertext)
        XCTAssertEqual(ciphertext!.base64EncodedString(), "AAAAAAAAAAAAAAAA/mXPbeIYU9cFvF0Si8p4ydeL")
    }
}
