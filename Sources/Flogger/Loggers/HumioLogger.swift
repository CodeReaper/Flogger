import Foundation
import UIKit
import os

public class HumioLogger {
    let endpoint: URL
    let token: String
    let allowsCellularAccess: Bool
    let frequencyTrigger: TimeInterval
    let amountTrigger: Int
    let tags: [String: String]

    private let delegate: Delegate
    let session: URLSession
    let storage: URL

    let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Humio")

    var cache = [[String: Any]]()
    var cacheQueue = DispatchQueue(label: "Humio.cache.queue")

    var observer: Any?
    var timer: Timer?

    public init(
        token: String? = nil,
        space: String? = nil,
        tags: [String: String] = [:],
        allowsCellularAccess: Bool = true,
        frequencyTrigger: TimeInterval = 60,
        amountTrigger: Int = 50
    ) {
        guard let token = token ?? Bundle.main.infoDictionary?["HUMIO_INGEST_TOKEN"] as? String else { fatalError("Did not find required 'HUMIO_INGEST_TOKEN' key in info.plist") }
        guard let space = space ?? Bundle.main.infoDictionary?["HUMIO_DATA_SPACE"] as? String else { fatalError("Did not find required 'HUMIO_DATA_SPACE' key in info.plist") }
        guard let endpoint = URL(string: "https://cloud.humio.com/api/v1/dataspaces/\(space)/ingest") else { fatalError("Unable to construct a valid URL with configured data space value: '\(space)'") }

        self.token = token
        self.endpoint = endpoint

        self.allowsCellularAccess = allowsCellularAccess
        self.frequencyTrigger = max(5, frequencyTrigger)
        self.amountTrigger = min(100, max(10, amountTrigger))

        var updatedTags = Self.defaultTags
        for (key, value) in tags {
            updatedTags[key] = value
        }
        self.tags = updatedTags

        self.storage = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try! FileManager.default.createDirectory(at: self.storage, withIntermediateDirectories: true)

        self.delegate = Delegate(logger: logger, storage: storage)

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.allowsCellularAccess = sessionConfiguration.allowsCellularAccess
        self.session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: .main)

        observer = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [flush] _ in
            flush()
        }

        DispatchQueue.main.async { [self] in
            self.timer = Timer.scheduledTimer(withTimeInterval: frequencyTrigger, repeats: true) { [flush] _ in
                flush()
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

    static var defaultTags: [String: String] {
        let version = ProcessInfo().operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        var sysinfo = utsname()
        uname(&sysinfo)
        let deviceIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return [
            "platform": "ios",
            "bundleIdentifier": Bundle.main.bundleIdentifier ?? "unknown",
            "CFBundleVersion": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "CFBundleShortVersionString": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "systemVersion": versionString,
            "deviceModel": deviceIdentifier
        ]
    }

    func queue(severity: Flogger.Level, _ message: String, _ file: String, _ line: Int) {
        let event: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "attributes": [
                "filename": URL(fileURLWithPath: file).lastPathComponent,
                "line": line,
                "level": severity.description
            ],
            "rawstring": message
        ]

        cacheQueue.async {
            self.cache.append(event)
            if self.cache.count >= self.amountTrigger {
                self.flush()
            }
        }
    }

    func flush() {
        cacheQueue.async {
            let cache = self.cache
            self.cache = []
            self.send(events: cache)
        }
    }

    func send(events: [[String: Any]]) {
        guard events.count > 0 else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let preparedEvents = [[
            "tags": tags,
            "events": events
        ]]

        let filename = "\(UUID().uuidString).humio"
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: preparedEvents, options: [])
        } catch {
            logger.error("Found error: \(error, privacy: .private) while serializing given events: \(preparedEvents, privacy: .private)")
            return
        }
        do {
            try data.write(to: storage.appendingPathComponent(filename))
        } catch {
            logger.error("Found error: \(error, privacy: .private) while persisting events")
            return
        }

        let task = session.uploadTask(with: request, from: data)
        task.taskDescription = filename
        task.resume()
    }
}

extension HumioLogger: Logger {
    public func debug(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .debug, message, file, line)
    }

    public func info(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .info, message, file, line)
    }

    public func warn(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .warn, message, file, line)
    }

    public func error(_ message: String, _ file: String = #file, _ line: Int = #line) {
        queue(severity: .error, message, file, line)
    }
}

private class Delegate: NSObject, URLSessionDataDelegate {
    let storage: URL
    let logger: os.Logger

    init(logger: os.Logger, storage: URL = URL(fileURLWithPath: ".")) {
        self.logger = logger
        self.storage = storage
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? -1
        let filename = task.taskDescription ?? "not-found"
        let file = storage.appendingPathComponent(filename)

        switch statusCode {
        case 200..<300, 400..<500:
            try? FileManager.default.removeItem(at: file)
        default:
            guard
                let data = try? Data(contentsOf: file, options: []),
                let request = task.originalRequest
            else {
                try? FileManager.default.removeItem(at: file)
                logger.warning("Unable to attempt retry for \(filename), statusCode was \(statusCode)")
                return
            }
            let nextTask = session.uploadTask(with: request, from: data)
            nextTask.taskDescription = task.taskDescription
            nextTask.resume()
        }
    }
}
