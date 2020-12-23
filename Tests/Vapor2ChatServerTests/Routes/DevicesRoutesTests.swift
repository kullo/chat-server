/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Testing
import Vapor
import XCTest

@testable import ChatServerTesting

class DevicesRoutesTests: RouterTestCase {
    func testRegisterWithNonJSONBody() throws {
        let req = try Request.make(method: .post, path: "/v1/test/devices")
        req.body = "This is not JSON.".makeBody()
        AssertThrowsAbortError(try router.respond(to: req), .unsupportedMediaType)
    }

    func testRegisterWithBrokenJSONBody() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            This is not JSON.
            """)
        AssertThrowsAbortError(try router.respond(to: req), .badRequest)
    }

    func testRegisterWithBadEmail() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "does.not.exist@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "Caxs1lMgstvfjqm3ccqLQca8t38GhO2PUh61VML3sBE=",
                    "state": "pending"
                }
            }
            """)
        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    func testRegisterWithWrongPassword() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "XGQVrM8E7ETvYArSGQL9CivjChh73/+Wek7YRpdZ4vQ=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "Caxs1lMgstvfjqm3ccqLQca8t38GhO2PUh61VML3sBE=",
                    "state": "pending"
                }
            }
            """)
        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    func testRegisterDeviceWithConflictingID() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "123abc",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "GwTUUtx599Fp/R2Isn//K5zCRRvYYYiP+hClK745hwE=",
                    "state": "pending"
                }
            }
            """)

        AssertThrowsAbortError(try router.respond(to: req), .conflict)
    }

    func testRegisterDeviceWithWrongOwnerID() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 23,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "GwTUUtx599Fp/R2Isn//K5zCRRvYYYiP+hClK745hwE=",
                    "state": "pending"
                }
            }
            """)

        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    func testRegisterDeviceWithWrongState() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "GwTUUtx599Fp/R2Isn//K5zCRRvYYYiP+hClK745hwE=",
                    "state": "active"
                }
            }
            """)

        AssertThrowsAbortError(try router.respond(to: req), .unprocessableEntity)
    }

    func testRegisterDeviceWithBlockTime() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "Caxs1lMgstvfjqm3ccqLQca8t38GhO2PUh61VML3sBE=",
                    "state": "pending",
                    "blockTime": "2018-01-01T00:00:00Z"
                }
            }
            """)

        AssertThrowsAbortError(try router.respond(to: req), .unprocessableEntity)
    }

    func testRegisterDevice() throws {
        let req = try Request.makeJSON(method: .post, path: "/v1/test/devices", body: """
            {
                "email": "answer@example.com",
                "passwordVerificationKey": "iNMTjnqTkFnnyZgumYzpHgpdFZAdX0x+CCso4Rsy3eM=",
                "device": {
                    "id": "60a0a2b646e18247f97ded4e30a65fd0",
                    "ownerId": 1,
                    "idOwnerIdSignature": "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                    "pubkey": "Caxs1lMgstvfjqm3ccqLQca8t38GhO2PUh61VML3sBE=",
                    "state": "pending"
                }
            }
            """)
        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .ok)
        AssertJSON(response: res, contains: """
            {
                "id" : "60a0a2b646e18247f97ded4e30a65fd0",
                "ownerId" : 1,
                "idOwnerIdSignature" : "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                "pubkey" : "Caxs1lMgstvfjqm3ccqLQca8t38GhO2PUh61VML3sBE=",
                "state" : "pending"
            }
            """)
    }

    func testGetDevicesRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .get, path: "/v1/test/devices"),
            router: router)
    }

    func testGetDevices() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices")
        req.addAuth()

        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .ok)
        // does also contain "related" with the owners, but we test that in testGetPendingDevices
        AssertJSON(response: res, contains: """
            {
                "objects": [
                    {
                        "id" : "123abc",
                        "ownerId" : 1,
                        "idOwnerIdSignature" : "A86TVs2o4eM2/0dswU2QcJT6Nxl5RnXl6tTT7XlaEN0=",
                        "pubkey" : "WTf5bFDh+3shgdJpHkTb4mxLE6IHHB/rj1KbehMaT9Q=",
                        "state" : "active"
                    },
                    {
                        "id" : "456def",
                        "ownerId" : 2,
                        "idOwnerIdSignature" : "asdf",
                        "pubkey" : "zVclGMiApcoBmoo4guY3a/vb4bpt8JPu7RLGx1oS9Q0=",
                        "state" : "active"
                    },
                    {
                        "id" : "789ghi",
                        "ownerId" : 1,
                        "idOwnerIdSignature" : "fdsa",
                        "pubkey" : "rewq",
                        "state" : "pending"
                    },
                    {
                        "id" : "abcjkl",
                        "ownerId" : 2,
                        "idOwnerIdSignature" : "asdfasdf",
                        "pubkey" : "qwerqwer",
                        "state" : "pending"
                    }
                ]
            }
            """)
    }

    func testGetPendingDevices() throws {
        let req = try Request.make(method: .get, path: "/v1/test/devices?state=pending")
        req.addAuth()

        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .ok)
        AssertJSON(response: res, contains: """
            {
                "objects": [
                    {
                        "id" : "789ghi",
                        "ownerId" : 1,
                        "idOwnerIdSignature" : "fdsa",
                        "pubkey" : "rewq",
                        "state" : "pending"
                    },
                    {
                        "id" : "abcjkl",
                        "ownerId" : 2,
                        "idOwnerIdSignature" : "asdfasdf",
                        "pubkey" : "qwerqwer",
                        "state" : "pending"
                    }
                ],
                "related": {
                    "users": [
                        {
                            "id": 1,
                            "state": "active",
                            "name": "The Answer",
                            "picture": "https://www.example.com/theanswer.jpg",
                            "encryptionPubkey": "DHsX+0kl70HiXXWWauoQviqWRY3/jMkGtLxTEsAEBSg="
                        },
                        {
                            "id": 2,
                            "state": "active",
                            "name": "Another User",
                            "picture": null,
                            "encryptionPubkey": "6DZ23+EtT8CrSLlmJtau9/ZFi4UmrJZ6Zd7RF6M1em8="
                        }
                    ]
                }
            }
            """)
    }

    func testPatchDeviceRequiresAuth() {
        AssertRequiresAuth(
            try Request.make(method: .patch, path: "/v1/test/devices/123abc"),
            router: router)
    }

    func testSetStateToPendingFails() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/789ghi", body: """
            {
                "state": "pending"
            }
            """)
        req.addAuth()

        AssertThrowsAbortError(try router.respond(to: req), .unprocessableEntity)
    }

    func testActivateNonPendingFails() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/123abc", body: """
            {
                "state": "active"
            }
            """)
        req.addAuth()

        AssertThrowsAbortError(try router.respond(to: req), .conflict)
    }

    func testActivate() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/789ghi", body: """
            {
                "state": "active"
            }
            """)
        req.addAuth()

        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .noContent)
    }

    func testActivateByAdminUser() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/abcjkl", body: """
            {
                "state": "active"
            }
            """)
        req.addAuth()

        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .noContent)
    }

    func testBlockDeviceRequiresAuthAsOwnerOfDevice() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/456def", body: """
            {
                "state": "blocked",
                "blockTime": "2018-01-01T00:00:00Z"
            }
            """)
        req.addAuth()

        AssertThrowsAbortError(try router.respond(to: req), .unauthorized)
    }

    func testBlockNonexistingDevice() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/nonexisting", body: """
            {
                "state": "blocked",
                "blockTime": "2018-01-01T00:00:00Z"
            }
            """)
        req.addAuth()

        AssertThrowsAbortError(try router.respond(to: req), .notFound)
    }

    func testBlockDeviceRequiresBlockTime() throws {
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/789ghi", body: """
            {
                "state": "blocked"
            }
            """)
        req.addAuth()

        AssertThrowsAbortError(try router.respond(to: req), .unprocessableEntity)
    }

    func testBlockDevice() throws {
        // block device
        let req = try Request.makeJSON(method: .patch, path: "/v1/test/devices/789ghi", body: """
            {
                "state": "blocked",
                "blockTime": "2018-01-01T00:00:00Z"
            }
            """)
        req.addAuth()
        let res = try router.respond(to: req)

        XCTAssertEqual(res.status, .noContent)

        // block device again
        let req2 = try Request.makeJSON(method: .patch, path: "/v1/test/devices/789ghi", body: """
            {
                "state": "blocked",
                "blockTime": "2018-01-01T00:00:00Z"
            }
            """)
        req2.addAuth()

        AssertThrowsAbortError(try router.respond(to: req2), .conflict)
    }
}
