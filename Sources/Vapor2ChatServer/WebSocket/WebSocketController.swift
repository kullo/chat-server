/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import Foundation
import RxSwift
import Vapor

private struct GenericRequest: Decodable {
    let type: String
    let id: Int
}

private struct AssembledWebSocketEvent: Encodable {
    let type: String
    let data: AnyEncodable
}

class WebSocketController<WebSocketType: WebSocketProtocol> {
    private let _servicesFactory: ServicesFactory
    private let _requestHandlers: [String: WebSocketRequestHandlerProtocol]

    private var _connections = [ObjectIdentifier: WebSocketConnection<WebSocketType>]()
    private let _disposeBag = DisposeBag()

    enum Error: String, Swift.Error, PubliclyDescribable {
        var publicDescription: String { return rawValue }

        case invalidRequestType = "Invalid request type"
    }

    init(
        servicesFactory: ServicesFactory,
        requestHandlers: [String: WebSocketRequestHandlerProtocol],
        events: Observable<WebSocketEvent>) {

        _servicesFactory = servicesFactory
        _requestHandlers = requestHandlers

        events.subscribe(handleEvent).disposed(by: _disposeBag)
    }

    private func handleEvent(_ rxEvent: RxSwift.Event<WebSocketEvent>) {
        do {
            switch rxEvent {
            case let .next(event):
                let encoder = CodecFactory.makeJSONEncoder()
                let assembled = AssembledWebSocketEvent(type: event.type, data: event.body)
                let encoded = try encoder.encode(assembled)
                for (id, connection) in _connections {
                    if id != event.origin && event.shouldBeSentTo(userID: connection.meta.userID) {
                        try connection.socket.send(String(data: encoded, encoding: .utf8)!)
                    }
                }
            case let .error(error): throw error
            case .completed: break
            }
        } catch {
            _servicesFactory.log.error("While handling event \(rxEvent): \(error)")
        }
    }

    func handleConnection(request upgradeRequest: Request, connection socket: WebSocketType) throws {
        let connection = WebSocketConnection(
            socket: socket,
            baseURL: upgradeRequest.baseURL(baseScheme: "http"),
            workspace: upgradeRequest.workspace,
            userID: upgradeRequest.userID!)
        _servicesFactory.log.info("WS \(connection.id.hashValue) connected")
        _connections[connection.id] = connection

        // Chrome seems to close WS connections after 30s, Heroku after 55s
        let pingInterval: RxTimeInterval = 25
        let pingDisposable = Observable<Int>
            .timer(
                pingInterval,
                period: pingInterval,
                scheduler: SerialDispatchQueueScheduler(
                    qos: .default,
                    internalSerialQueueName: "de.kullo.ws-connection-queue"))
            .subscribe({ [log = _servicesFactory.log] _ in
                do {
                    log.info("WS \(connection.id.hashValue) ping")
                    try socket.ping()
                } catch {
                    try? socket.close()
                }
            })

        socket.onClose = { [weak self] socket, statusCode, reason, cleanly throws in
            self?._servicesFactory.log.info(
                "WS \(connection.id.hashValue) disconnected, " +
                "statusCode: \(String(describing: statusCode)), " +
                "cleanly: \(cleanly), " +
                "reason: \(reason ?? "-")")
            self?._connections.removeValue(forKey: connection.id)
            pingDisposable.dispose()
        }

        socket.onText = { [weak self] socket, text throws -> Void in
            guard let strongSelf = self else { return }

            let data = Data(text.utf8)
            let genericRequest: GenericRequest
            do {
                let decoder = CodecFactory.makeJSONDecoder()
                genericRequest = try decoder.decode(GenericRequest.self, from: data)
            } catch {
                strongSelf._servicesFactory.log.error("\(error)")
                try socket.close(
                    statusCode: 1003, // unsupported data
                    reason: "couldn't parse basic request data (type, ID)")
                return
            }
            try strongSelf.handleRequest(data, genericRequest: genericRequest, from: connection)
        }

        socket.onBinary = { [log = _servicesFactory.log] socket, bytes throws in
            log.warning("WS \(connection.id.hashValue) binary msg received")
            try socket.close(
                statusCode: 1003, // unsupported data
                reason: "binary messages are not supported")
        }
    }

    private func handleRequest(
        _ message: Data,
        genericRequest: GenericRequest,
        from connection: WebSocketConnection<WebSocketType>) throws {

        let encodedResponse: Data
        do {
            guard let requestHandler = _requestHandlers[genericRequest.type] else {
                throw Error.invalidRequestType
            }
            encodedResponse = try requestHandler.makeResponse(
                connection: connection.meta, requestBody: message, servicesFactory: _servicesFactory)

        } catch {
            _servicesFactory.log.error("While handling WS request: \(error)")
            let response = ResponseEvent.makeError(requestID: genericRequest.id, error: error)
            encodedResponse = try CodecFactory.makeJSONEncoder().encode(response)
        }

        try connection.socket.send(String(data: encodedResponse, encoding: .utf8)!)
    }
}
