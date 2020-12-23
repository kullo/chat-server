/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
struct TestError: Error {
    let message: String

    static let invalidBodyType = TestError(message: "Invalid body type")
}
