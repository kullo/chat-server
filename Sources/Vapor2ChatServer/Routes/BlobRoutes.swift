/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
//TODO: remove import, then remove FluentServices from Vapor2ChatServer's dependencies in Package.swift
import FluentServices
import Foundation
import Vapor

class BlobRoutes: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        let blob = builder.grouped("blob")

        blob.get(String.parameter) { request in
            let name = try request.parameters.next(String.self)
            guard let blob = try BlobEntity.makeQuery().find(name) else {
                throw Abort(.notFound)
            }
            return Response(status: .ok, headers: [.contentType: blob.contentType], body: blob.data)
        }

        blob.put(String.parameter) { request in
            let name = try request.parameters.next(String.self)
            guard try BlobEntity.makeQuery().filter("id", name).count() == 0 else {
                throw Abort(.conflict, reason: "Blob does already exist")
            }

            let contentType = request.contentType ?? "application/octet-stream"
            switch request.body {
            case let .data(bytes):
                let data = Data(bytes: bytes)
                try BlobEntity(id: name, contentType: contentType, data: data).save()
            case .chunked:
                throw Abort(.badRequest)
            }
            return Response(status: .noContent)
        }
    }
}
