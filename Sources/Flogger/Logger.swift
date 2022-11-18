import Foundation

public protocol Logger {
    func debug(_ message: String, _ file: String, _ line: Int)
    func info(_ message: String, _ file: String, _ line: Int)
    func warn(_ message: String, _ file: String, _ line: Int)
    func error(_ message: String, _ file: String, _ line: Int)
}
