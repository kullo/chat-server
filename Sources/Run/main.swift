/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import ChatServer
import FluentServices
import Vapor2ChatServer
import Vapor

let config = try Config()
try App.setup(config: config)

let droplet = try Droplet(config: config)

try FluentServices.setup(deleteAllData: false)
let servicesFactory = FluentServicesFactory(
    logger: VaporLogService(logger: droplet.log), authTokens: AuthTokenManager())

try App.setup(droplet: droplet, servicesFactory: servicesFactory)

try droplet.run()
