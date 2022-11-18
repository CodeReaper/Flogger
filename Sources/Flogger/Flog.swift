import Foundation

public struct Flog {
    static var instance: Flogger!

    public static func debug(_ message: String, file: String = #file, line: Int = #line) {
        instance.debug(message, file, line)
    }

    public static func info(_ message: String, file: String = #file, line: Int = #line) {
        instance.info(message, file, line)
    }

    public static func warn(_ message: String, file: String = #file, line: Int = #line) {
        instance.warn(message, file, line)
    }

    public static func error(_ message: String, file: String = #file, line: Int = #line) {
        instance.error(message, file, line)
    }
}
