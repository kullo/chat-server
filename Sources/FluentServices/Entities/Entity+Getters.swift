/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Fluent

protocol ModelConvertible {
    associatedtype ModelType
    func makeModel() throws -> ModelType
}

extension Entity where Self: ModelConvertible {
    static func getMultiple(
        filter: (Query<Self>) throws -> [Self]) -> ServiceResult<[ModelType]> {

        do {
            return .success(try filter(makeQuery()).map({ try $0.makeModel() }))
        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }

    static func getOne(
        filter: (Query<Self>) throws -> Self?) -> ServiceResult<ModelType?> {

        do {
            return .success(try filter(makeQuery())?.makeModel())
        } catch {
            var serviceError = FluentServiceError.generalDatabaseError
            serviceError.reason = error
            return .error(serviceError)
        }
    }
}
