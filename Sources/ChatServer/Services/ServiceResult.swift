/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
public enum ServiceResult<SuccessType> {
    case success(SuccessType)
    case error(PubliclyDescribableError)

    public var successValue: SuccessType? {
        switch self {
        case let .success(value):
            return value
        default:
            return nil
        }
    }
}
