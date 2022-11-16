import Foundation

extension Humio {
    func queue(severity: Level, _ message: String, _ file: String, _ line: Int) {
        if configuration.printMessages {
            print("\(message)")
        }

        guard configuration.enabled && configuration.level.rawValue <= severity.rawValue else { return }

        let event: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "attributes": [
                "filename": URL(fileURLWithPath: file).lastPathComponent,
                "line": line,
                "level": severity
            ],
            "rawstring": message
        ]

        cacheQueue.async {
            self.cache.append(event)
            if self.cache.count >= self.configuration.amountTrigger {
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
}
