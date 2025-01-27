import Foundation
import UIKit
import os

public class FileLogger {
    private let filePrefix = "%d.log"
    private let frequencyTrigger: TimeInterval = 10

    let directory: URL
    let maximumFileSize: UInt
    let maximumFileAge: TimeInterval
    let maximumNumberOfFiles: Int

    private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "File")
    private var queue = DispatchQueue(label: "File.queue")

    private var observer: Any?
    private var timer: Timer?

    // FIXME: add file handle for current log file
    // - https://stackoverflow.com/a/77563403/190599

    public init(directory: URL? = nil) {
        if let directory = directory {
            self.directory = directory
        } else {
            self.directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        }
        try! FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)

        // FIXME: determine and open file handle for current log file

        // FIXME - make these configurable
        maximumFileSize = 1024 * 1024 * 5
        maximumFileAge = 60 * 60 * 24
        maximumNumberOfFiles = 2

        observer = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [rotate] _ in
            rotate()
        }

        DispatchQueue.main.async { [self] in
            self.timer = Timer.scheduledTimer(withTimeInterval: frequencyTrigger, repeats: true) { [rotate] _ in
                rotate()
            }
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func rotate() {
        // FIXME: rotate file handle if needed
    }

    private func queue(severity: Flogger.Level, _ message: String, _ file: String, _ line: Int) {
        queue.async {
            // FIXME: write to file if needed
        }
    }
}

extension FileLogger: Logger {
    public func debug(_ message: String, _ file: String, _ line: Int) {
        queue(severity: .debug, message, file, line)
    }

    public func info(_ message: String, _ file: String, _ line: Int) {
        queue(severity: .info, message, file, line)
    }

    public func warn(_ message: String, _ file: String, _ line: Int) {
        queue(severity: .warn, message, file, line)
    }

    public func error(_ message: String, _ file: String, _ line: Int) {
        queue(severity: .error, message, file, line)
    }
}
