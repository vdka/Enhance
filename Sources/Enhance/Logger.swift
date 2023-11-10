
import OSLog

/// Internal logger used by Enhance
let log = Logger(subsystem: "io.github.vdka.enhance", category: "General")
let signpost = OSSignposter(logger: log) // The signposter object. Exposed so it can be used directly.

extension Logger {
    subscript(category: String) -> Logger {
        return Logger(subsystem: "io.github.vdka.sqlite", category: category)
    }

    /// In Debug will call to ``Swift.assert``, and in Release will log a critical error
    func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String = String(),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard !condition() else { return }
        var message = message()
        if message.isEmpty {
            message = "Assertion Failed. \(file):\(line)"
        }
        self.log(level: .fault, "\(message)")
        Swift.assert(!condition(), message, file: file, line: line)
    }
}
