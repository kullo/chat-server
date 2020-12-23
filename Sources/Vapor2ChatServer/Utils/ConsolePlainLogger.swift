/*
 * Copyright 2018 Kullo GmbH
 *
 * This source code is licensed under the 3-clause BSD license. See LICENSE.txt
 * in the root directory of this source tree for details.
 */
import Console
import Vapor

final class ConsolePlainLogger: LogProtocol {
    private let _console: ConsoleProtocol

    var enabled = Vapor.LogLevel.all

    init(_ console: ConsoleProtocol) {
        _console = console
    }

    func log(
        _ level: Vapor.LogLevel,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line) {

        if enabled.contains(level) {
            _console.output("[\(level.description.first!)] \(message)")
        }
    }
}

extension ConsolePlainLogger: ConfigInitializable {
    convenience init(config: Config) throws {
        self.init(try config.resolveConsole())
    }
}
