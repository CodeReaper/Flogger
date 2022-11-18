import Foundation

public struct ConsoleLogger: Logger {
    public init() { }

    public func debug(_ message: String, _ file: String, _ line: Int) {
        print("D \(message)")
    }

    public func info(_ message: String, _ file: String, _ line: Int) {
        print("I \(message)")
    }

    public func warn(_ message: String, _ file: String, _ line: Int) {
        print("W \(message)")
    }

    public func error(_ message: String, _ file: String, _ line: Int) {
        print("E \(message)")
    }
}
