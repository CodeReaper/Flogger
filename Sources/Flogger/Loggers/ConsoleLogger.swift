import Foundation

public struct ConsoleLogger: Logger {
    public init() { }

    public func debug(_ message: String, _ file: String, _ line: Int) {
        print("\(message)")
    }

    public func info(_ message: String, _ file: String, _ line: Int) {
        print("\(message)")
    }

    public func warn(_ message: String, _ file: String, _ line: Int) {
        print("\(message)")
    }

    public func error(_ message: String, _ file: String, _ line: Int) {
        print("\(message)")
    }
}
