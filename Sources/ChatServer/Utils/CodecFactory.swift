/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public final class CodecFactory {
    public static func makeJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        #if os(Linux)
            encoder.dateEncodingStrategy = .iso8601
        #else
            if #available(OSX 10.12, *) {
                encoder.dateEncodingStrategy = .iso8601
            } else {
                fatalError("ISO 8601 support for Codable is not available on this OS version")
            }
        #endif
        return encoder
    }

    public static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        #if os(Linux)
            decoder.dateDecodingStrategy = .iso8601
        #else
            if #available(OSX 10.12, *) {
                decoder.dateDecodingStrategy = .iso8601
            } else {
                fatalError("ISO 8601 support for Codable is not available on this OS version")
            }
        #endif
        return decoder
    }
}
