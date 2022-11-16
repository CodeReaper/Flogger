import Foundation
import UIKit
import os

public class Humio {
    let endpoint: URL
    let token: String
    let tags: [String: String]

    let configuration: Configuration
    let session: URLSession
    let delegate: Delegate
    let storage: URL

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Humio")

    var cache = [[String: Any]]()
    var cacheQueue = DispatchQueue(label: "Humio.cache.queue")

    var observer: Any?
    var timer: Timer?

    init(configuration: Configuration, token: String? = nil, space: String? = nil) {
        self.configuration = configuration

        guard configuration.enabled else {
            self.token = ""
            self.storage = URL(fileURLWithPath: ".")
            self.endpoint = URL(fileURLWithPath: ".")
            self.tags = [:]
            self.session = URLSession.shared
            self.delegate = Delegate(logger: logger)
            logger.warning("Humio was set up to be disabled.")
            return
        }

        guard let token = token ?? Bundle.main.infoDictionary?["HUMIO_INGEST_TOKEN"] as? String else { fatalError("Did not find required 'HUMIO_INGEST_TOKEN' key in info.plist") }
        guard let space = space ?? Bundle.main.infoDictionary?["HUMIO_DATA_SPACE"] as? String else { fatalError("Did not find required 'HUMIO_DATA_SPACE' key in info.plist") }
        guard let endpoint = URL(string: "https://cloud.humio.com/api/v1/dataspaces/\(space)/ingest") else { fatalError("Unable to construct a valid URL with configured data space value: '\(space)'") }

        self.token = token
        self.endpoint = endpoint

        var tags = Self.tags
        for (key, value) in configuration.tags {
            tags[key] = value
        }
        self.tags = tags

        self.storage = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        self.delegate = Delegate(logger: logger, storage: storage)

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.allowsCellularAccess = sessionConfiguration.allowsCellularAccess
        self.session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: .main)

        observer = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [flush] _ in
            flush()
        }

        DispatchQueue.main.async { [self] in
            self.timer = Timer.scheduledTimer(withTimeInterval: configuration.frequencyTrigger, repeats: true) { [flush] _ in
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
}
