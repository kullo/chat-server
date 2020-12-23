/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public struct Attachment: Codable {
    let id: String
    let uploadUrl: URL
}

public struct NewAttachments: Codable {
    let count: Int
}
