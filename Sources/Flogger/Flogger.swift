import Foundation

public struct Flogger {
    private let level: Level

    private var loggers: [Logger] = []

    public init(level: Level = .info) {
        self.level = level
        Flog.instance = self
    }

    public mutating func add(_ logger: Logger) {
        loggers.append(logger)
    }

    func log(severity: Level, _ message: String, _ file: String, _ line: Int) {
        guard level.rawValue <= severity.rawValue else { return }

        switch level {
        case .debug:
            loggers.forEach { $0.debug(message, file, line) }
        case .info:
            loggers.forEach { $0.info(message, file, line) }
        case .warn:
            loggers.forEach { $0.warn(message, file, line) }
        case .error:
            loggers.forEach { $0.error(message, file, line) }
        }
    }
}

extension Flogger: Logger {
    public func debug(_ message: String, _ file: String = #file, _ line: Int = #line) {
        log(severity: .debug, message, file, line)
    }

    public func info(_ message: String, _ file: String = #file, _ line: Int = #line) {
        log(severity: .info, message, file, line)
    }

    public func warn(_ message: String, _ file: String = #file, _ line: Int = #line) {
        log(severity: .warn, message, file, line)
    }

    public func error(_ message: String, _ file: String = #file, _ line: Int = #line) {
        log(severity: .error, message, file, line)
    }
}
