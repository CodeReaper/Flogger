import Foundation

extension Humio {
    func send(events: [[String: Any]]) {
        guard events.count > 0 else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let preparedEvents = [[
            "tags": configuration.tags,
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
