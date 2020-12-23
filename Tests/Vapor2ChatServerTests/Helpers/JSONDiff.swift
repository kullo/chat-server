/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

class JSONDiff {
    static func diff(_ lhs: Any, contains rhs: Any) -> Bool {
        switch (lhs, rhs) {
        case let (result, expected) as ([String: Any], [String: Any]):
            for key in expected.keys {
                if !diff(result[key] as Any, contains: expected[key] as Any) { return false }
            }
            return true
        case let (result, expected) as ([Any], [Any]):
            if result.count != expected.count { return false }
            for (r, e) in zip(result, expected) {
                if !diff(r, contains: e) { return false }
            }
            return true
        case let (result, expected) as (String, String):
            return result == expected
        case let (result, expected) as (NSNumber, NSNumber):
            return result == expected
        case let (result, expected) as (Int, Int):
            return result == expected
        case let (result, expected) as (Double, Double):
            return result == expected
        case let (result, expected) as (Bool, Bool):
            return result == expected
        case (_, _) as (Any, NSNull):
            return true
        default:
            return false
        }
    }
}
