import Foundation

extension Humio {
    public enum Level: Int {
        case debug = 0, info, warn, error
    }
}

extension Humio.Level: CustomStringConvertible {
    public var description: String {
        switch self {
        case .debug: return "debug"
        case .info: return "info"
        case .warn: return "warn"
        case .error: return "error"
        }
    }
}
