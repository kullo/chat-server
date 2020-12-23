/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
struct ListResult<Object: Encodable, Related: Encodable>: Encodable {
    let objects: [Object]
    let related: Related
    let meta: ListMeta
}

struct ListMeta: Encodable {
    let nextCursor: String?
}
