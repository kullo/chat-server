/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Foundation
import Vapor

extension Request {
    func baseURL(baseScheme: String) -> URLComponents {
        var components = URLComponents()
        components.host = uri.hostname
        components.scheme = components.host! == "localhost" ? "\(baseScheme)" : "\(baseScheme)s"
        if let port = uri.port, port != URI.defaultPorts[components.scheme!] {
            components.port = Int(port)
        }
        return components
    }
}
