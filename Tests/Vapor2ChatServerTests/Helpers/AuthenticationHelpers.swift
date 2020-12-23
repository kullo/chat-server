/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Vapor
import XCTest

extension Request {
    func addAuth(deviceID: String = "123abc") {
        switch deviceID {
        case "123abc":
            headers[.authorization] = "KULLO_V1 " +
                "loginKey=\"V0nrrLcHcPcf1nuQoTnBIDKczv+LbXjJeTKyL5LTW+o=\", " +
                "signature=\"123abc,48K3wXVVB/TL+t1E/VLNBi0xsHz4dv9i0Bt4pDUpL+52390tcx/8HB4qiPGpQVUm3NY55cnjt87wxKKbXC3WAQ==\""
        case "456def":
            headers[.authorization] = "KULLO_V1 " +
                "loginKey=\"FjZm3zzguy6EboHBAH+IZd2DWOp3mTpXFah2CRv5wTc=\", " +
                "signature=\"456def,M8ySQnw9LEX0qfkQCWvVLuk5ocsv/rzn1Fuam9Q3EI0mjO71SnvLoURHYs3DevY2Mo8ZnpUmszNPRT/wu5xiAw==\""
        default:
            XCTFail("addAuth not implemented for device \"\(deviceID)\"")
        }
    }
}

func AssertRequiresAuth(
    _ makeReq: @autoclosure () throws -> Request,
    router: Router,
    file: StaticString = #file,
    line: UInt = #line) {

    let reqNoAuth = try! makeReq()
    AssertThrowsAbortError(
        try router.respond(to: reqNoAuth), .unauthorized, file: file, line: line)

    let reqBadDeviceID = try! makeReq()
    reqBadDeviceID.headers[.authorization] = "KULLO_V1 " +
        "loginKey=\"V0nrrLcHcPcf1nuQoTnBIDKczv+LbXjJeTKyL5LTW+o=\", " +
        "signature=\"456def,48K3wXVVB/TL+t1E/VLNBi0xsHz4dv9i0Bt4pDUpL+52390tcx/8HB4qiPGpQVUm3NY55cnjt87wxKKbXC3WAQ==\""
    AssertThrowsAbortError(
        try router.respond(to: reqBadDeviceID), .unauthorized, file: file, line: line)

    let reqBadLoginKey = try! makeReq()
    reqBadLoginKey.headers[.authorization] = "KULLO_V1 " +
        "loginKey=\"asdf\", " +
        "signature=\"123abc,48K3wXVVB/TL+t1E/VLNBi0xsHz4dv9i0Bt4pDUpL+52390tcx/8HB4qiPGpQVUm3NY55cnjt87wxKKbXC3WAQ==\""
    AssertThrowsAbortError(
        try router.respond(to: reqBadLoginKey), .unauthorized, file: file, line: line)

    let reqBadSignature = try! makeReq()
    reqBadSignature.headers[.authorization] = "KULLO_V1 " +
        "loginKey=\"V0nrrLcHcPcf1nuQoTnBIDKczv+LbXjJeTKyL5LTW+o=\", " +
        "signature=\"123abc,aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\""
    AssertThrowsAbortError(
        try router.respond(to: reqBadSignature), .unauthorized, file: file, line: line)
}
