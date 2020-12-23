/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation

public extension Operation {
    static func addAttachments(
        ctx: RequestContext, newAttachments: NewAttachments, baseURL: URLComponents
        ) -> OperationResult<[Attachment]> {

        guard newAttachments.count <= 20 else {
            return .error(HandlerError(
                status: .unprocessableEntity, publicDescription: "Attachment limit exceeded"))
        }
        guard let baseUploadURL = baseURL.url?.appendingPathComponent("blob") else {
            return .error(HandlerError(
                status: .internalServerError, publicDescription: "Invalid base URL"))
        }

        let attachments: [Attachment] = (0..<newAttachments.count).map { _ in
            let id = UUID().uuidString
            return Attachment(id: id, uploadUrl: baseUploadURL.appendingPathComponent(id))
        }
        return .ok(attachments)
    }
}
