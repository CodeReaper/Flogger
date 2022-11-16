import Foundation
import os

class Delegate: NSObject, URLSessionDataDelegate {
    let storage: URL
    let logger: Logger

    init(logger: Logger, storage: URL = URL(fileURLWithPath: ".")) {
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
