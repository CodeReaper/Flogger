import Foundation

public struct ConsoleLogger {
    private let levelMarkers: [String]
    private let includeFilePath: Bool
    private let includeFileName: Bool

    public init(
        levelMarkers: [String] = ["D","I","W","E"],
        includeFilePath: Bool = false,
        includeFileName: Bool = false
    ) {
        assert(levelMarkers.count == 4)
        self.levelMarkers = levelMarkers
        self.includeFilePath = includeFilePath
        self.includeFileName = includeFileName
    }

    private func log(_ level: String, _ message: String, _ file: String, _ line: Int) {
        print([level, path(file, line), message].compactMap({ $0 }).joined(separator: " "))
    }

    private func path(_ file: String, _ line: Int) -> String? {
        guard includeFileName || includeFilePath, let url = URL(string: file) else {
            return nil
        }

        if includeFilePath {
            return "\(file):\(line)"
        } else {
            return "\(url.lastPathComponent):\(line)"
        }
    }
}

extension ConsoleLogger: Logger {
    public func debug(_ message: String, _ file: String, _ line: Int) {
        log(levelMarkers[0], message, file, line)
    }

    public func info(_ message: String, _ file: String, _ line: Int) {
        log(levelMarkers[1], message, file, line)
    }

    public func warn(_ message: String, _ file: String, _ line: Int) {
        log(levelMarkers[2], message, file, line)
    }

    public func error(_ message: String, _ file: String, _ line: Int) {
        log(levelMarkers[3], message, file, line)
    }
}
