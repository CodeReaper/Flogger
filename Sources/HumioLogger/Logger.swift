import Foundation

extension Humio {
    static var instance: Humio!

    public static func setup(level: Level = .info, enabled: Bool = true, enabledPrintMessages: Bool = true, allowsCellularAccess: Bool = true, frequencyTrigger: TimeInterval = 60, amountTrigger: Int = 50, additionalTags: [String: String] = [:]) {
        guard instance == nil else { fatalError("Calling setup(...) multiple times is not supported.") }

        let configuration = Configuration(
            level: level,
            enabled: enabled,
            printMessages: enabledPrintMessages,
            allowsCellularAccess: allowsCellularAccess,
            frequencyTrigger: max(5, frequencyTrigger),
            amountTrigger: min(100, max(10, amountTrigger)),
            tags: additionalTags
        )
        instance = Humio(configuration: configuration)
    }

    public static func debug(_ message: String, file: String = #file, line: Int = #line) {
        guard instance != nil else { fatalError("A logging statement was attempted before setup(...) was called.") }
        instance.debug(message, file, line)
    }

    public static func info(_ message: String, file: String = #file, line: Int = #line) {
        guard instance != nil else { fatalError("A logging statement was attempted before setup(...) was called.") }
        instance.info(message, file, line)
    }

    public static func warn(_ message: String, file: String = #file, line: Int = #line) {
        guard instance != nil else { fatalError("A logging statement was attempted before setup(...) was called.") }
        instance.warn(message, file, line)
    }

    public static func error(_ message: String, file: String = #file, line: Int = #line) {
        guard instance != nil else { fatalError("A logging statement was attempted before setup(...) was called.") }
        instance.error(message, file, line)
    }

    func debug(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .debug, message, file, line)
    }

    func info(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .info, message, file, line)
    }

    func warn(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .warn, message, file, line)
    }

    func error(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .error, message, file, line)
    }
}
